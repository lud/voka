defmodule Voka do
  @max_words 10

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
    # |> Stream.flat_map(& &1)
    |> Stream.map(fn spec ->
      spec |> IO.inspect(label: "spec")
    end)
    |> Stream.run()
  end

  def select_french_words do
    ~w(mort retourner)

    # Voka.FrenchFreq.get_most_used_words()
  end

  def add_spanish_translations(word) do
    Voka.OSDict.fra_to_spa(word)
  end

  def add_spanish_phonetics(definitions) do
    definitions |> IO.inspect(label: "definitions")

    definitions
    |> Enum.map(fn %{nature: nature, translations: tls} = defn ->
      tls =
        tls
        |> Enum.map(fn %{trans: t} = tc ->
          case find_spanish_phonetic(t, nature) do
            {:ok_xxxxx, found} -> {true, found}
          end
        end)
    end)
  end

  defp find_spanish_phonetic(word, nature) do
    case Voka.OSDict.spa_to_eng(word) do
      {:ok, :cool} -> {:ok, :cool}
    end
  end
end
