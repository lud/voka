defmodule Voka.Deepl do
  @endpoint "https://api-free.deepl.com/v2"

  def languages() do
    http_client(:get_json)
    |> Tesla.get("/languages")
  end

  def trans_word(word, source_lang, target_lang) do
    data = %{
      target_lang: target_lang,
      source_lang: source_lang,
      text: word
    }

    http_client(:form_json)
    |> Tesla.post("/translate", data)
  end

  defp http_client(:get_json) do
    middleware = [
      {Tesla.Middleware.BaseUrl, @endpoint},
      Tesla.Middleware.JSON,
      {Tesla.Middleware.Query, auth_key: secret_key()},
      Voka.TeslaCache
    ]

    Tesla.client(middleware)
  end

  defp http_client(:form_json) do
    middleware = [
      {Tesla.Middleware.BaseUrl, @endpoint},
      Tesla.Middleware.FormUrlencoded,
      Tesla.Middleware.JSON,
      {Tesla.Middleware.Query, auth_key: secret_key()},
      Voka.TeslaCache
    ]

    Tesla.client(middleware)
  end

  [:secret_key]
  |> Enum.each(fn k ->
    defp unquote(k)() do
      Application.get_env(:voka, __MODULE__)[unquote(k)]
    end
  end)
end
