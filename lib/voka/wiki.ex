defmodule Voka.Wiki do
  require Logger

  def trans_word(word, source_lang, target_lang) do
    with {:ok, result} <- word_page(word, source_lang) do
      extract_translation(result.body, target_lang, word)
    end
  end

  defp extract_translation(%{"parse" => %{"iwlinks" => links}}, target_lang, word) do
    links
    |> Enum.find(fn %{"prefix" => p} -> p == target_lang end)
    |> case do
      nil -> {:error, {:no_trans, word, target_lang}}
      %{"*" => <<^target_lang::binary-size(2), ":", translation::binary>>} -> {:ok, translation}
    end
  end

  def get_phonetic(word, source_lang) do
    with {:ok, result} <- word_page(word, source_lang) do
      extract_phonetic(result.body, source_lang, word)
    end
  end

  defp extract_phonetic(%{"parse" => %{"text" => %{"*" => text}}}, source_lang, word) do
    with {:ok, doc} <- Floki.parse_document(text) do
      doc
      |> find_ipa(source_lang)
      |> case do
        nil ->
          {:error, {:no_phonetic_found, word, source_lang}}

        ph ->
          ph
          |> String.trim()
          |> String.trim("/")
          |> then(&"/#{&1}/")
          |> Ark.Ok.wok()
      end
    end
  end

  defp extract_phonetic(_, _, _) do
    {:error, :bad_page}
  end

  defp find_ipa(doc, "es") do
    doc
    |> Floki.find("span")
    |> Enum.filter(fn el ->
      case Floki.attribute(el, "style") do
        ["color:#368BC1"] -> true
        _ -> false
      end
    end)
    |> first_text
  end

  defp find_ipa(doc, "ca") do
    Floki.find(doc, "span.IPA")
    |> first_text
  end

  defp first_text(els) do
    case els do
      [] -> nil
      [span | _] -> Floki.text(span)
    end
  end

  def word_page(word, lang) do
    query = [action: :parse, page: word, format: :json]
    url = "https://#{lang}.wiktionary.org/w/api.php"
    # Logger.debug("call #{url}?" <> Tesla.encode_query(query))

    http_client()
    |> Tesla.request(query: query, method: :get, url: url)
    |> case do
      {:ok, %{status: 200} = r} -> {:ok, r}
      {:error, _} = err -> err
    end
  end

  defp http_client() do
    middleware = [
      Tesla.Middleware.JSON,
      Voka.TeslaCache
    ]

    Tesla.client(middleware)
  end
end
