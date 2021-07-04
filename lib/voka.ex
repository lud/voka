defmodule Voka do
  require Logger

  def run do
    # select from a list of french words
    select_french_words()
    # add spanish translations. each word will come with several definitions (a
    # same word can be an adjective, a noun, etc).
    # and each definition can have multiple spanish translations
    |> Task.async_stream(&handle_word/1, timeout: :infinity)
    |> Stream.map(&Ark.Ok.uok!/1)
    |> Stream.filter(&Ark.Ok.ok?/1)
    |> Stream.map(&Ark.Ok.uok!/1)
    |> Stream.take(16 * 24)
  end

  def run_to_file do
    run()
    |> Voka.ResultCsv.stream_to_file()
    |> Stream.run()
  end

  defp handle_word(word) do
    IO.puts("trans: #{word}")

    with {:ok, es} <- Voka.Wiki.trans_word(word, "fr", "es"),
         #  IO.puts(" -> (es) #{es}"),
         {:ok, ca} <- Voka.Wiki.trans_word(word, "fr", "ca"),
         #  IO.puts(" -> (ca) #{ca}"),
         {:ok, es_p} <- Voka.Wiki.get_phonetic(es, "es"),
         #  IO.puts(" -> (es) #{es_p}"),
         {:ok, ca_p} <- Voka.Wiki.get_phonetic(ca, "ca"),
         #  IO.puts(" -> (ca) #{ca_p}") ,
         :ok do
      {:ok, %{word: word, es: es, ca: ca, es_p: es_p, ca_p: ca_p}}
    else
      {:error, err} ->
        Logger.error(inspect(err))
        err
    end
  end

  @stop_words ~w(si ah le la les de du et un une des à je tu il elle on nous vous ils elles ou me te se ma ta sa)

  defp select_french_words do
    # ~w(mort retourner)

    Voka.FrenchFreq.get_most_used_words()
    |> Enum.reject(fn
      basic
      when basic in @stop_words ->
        true

      _ ->
        false
    end)
  end
end
