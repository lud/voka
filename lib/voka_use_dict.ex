defmodule Voka.UseDict do
  @max_words 800

  def run do
    # select from a list of french words
    select_french_words()
    # add spanish translations. each word will come with several definitions (a
    # same word can be an adjective, a noun, etc).
    # and each definition can have multiple spanish translations
    |> Stream.map(&add_spanish_translations/1)
    |> Stream.filter(fn
      {:ok, _} -> true
      {:error, _} -> false
    end)
    |> Stream.map(fn {:ok, x} -> x end)
    |> Stream.take(@max_words)
    # for each definition/translation, we will try to add the spanish phonetic
    |> Stream.map(&add_spanish_phonetics/1)
    |> Enum.filter_map(&(&1 != :error), &elem(&1, 1))
    # |> Stream.flat_map(& &1)
    |> Stream.map(fn spec ->
      spec |> IO.inspect(label: "spec")
    end)
    |> Enum.map(&IO.inspect/1)
  end

  def select_french_words do
    # ~w(mort retourner)

    Voka.FrenchFreq.get_most_used_words()
    |> Enum.reject(fn
      basic when basic in ~w(le la les du et un une des à a) -> true
      _ -> false
    end)
  end

  def add_spanish_translations(word) do
    Voka.OSDict.fra_to_spa(word)
  end

  def add_spanish_phonetics(definitions) do
    # for each definition of the word,
    #   for each translation of the definition
    #     add the spanish phonetic if found or drop the translation
    # then remove the defintions without phonetics
    # finally take a single definition by using a score
    definitions |> IO.inspect(label: "definitions")

    definitions
    |> Enum.map(fn %{nature: nature, translations: tls} = defn ->
      tls =
        tls
        |> Enum.flat_map(fn %{trans: t} = tc ->
          case find_spanish_phonetic(t, nature) do
            {:ok, spa_phonetic} -> [Map.put(tc, :phonetic, spa_phonetic)]
            # no phonetic: drop
            _ -> []
          end
        end)

      Map.put(defn, :translations, tls)
    end)
    |> Enum.filter(&(length(&1.translations) > 0))
    |> case do
      [] ->
        :error

      list ->
        top =
          list
          |> Enum.sort_by(&definition_priority/1)
          |> hd

        {:ok, top}
    end
  end

  # priorities : zero is high priority, +Infinity is low priority
  defp definition_priority(%{nature: "v" <> _}), do: 0
  defp definition_priority(%{nature: "n"}), do: 1
  defp definition_priority(%{nature: "n," <> _}), do: 1
  defp definition_priority(%{nature: "masc"}), do: 1

  defp definition_priority(%{nature: "adj," <> _}), do: 10
  defp definition_priority(%{nature: "adj"}), do: 10
  defp definition_priority(%{nature: "adv"}), do: 10

  defp definition_priority(%{nature: "pn"}), do: 15
  defp definition_priority(%{nature: "pn," <> _}), do: 15
  defp definition_priority(%{nature: []}), do: 20

  defp find_spanish_phonetic(word, source_nature) do
    case Voka.OSDict.spa_to_eng(word) do
      {:error, _} = err ->
        err

      {:ok, trans} ->
        trans
        # priorize same nature in case same word ha different phonetics
        |> Enum.sort_by(fn %{phonetic: p, nature: trans_nature} when is_binary(p) ->
          if same_nature?(source_nature, trans_nature) do
            0
          else
            1
          end
        end)
        |> case do
          [] -> :error
          [head | _] -> {:ok, head.phonetic}
        end
    end
  end

  defp same_nature?([], _), do: false
  defp same_nature?(_, []), do: false
  defp same_nature?("pn" <> _, "pn" <> _), do: true

  defp same_nature?(:a, :a) do
    false
  end
end
