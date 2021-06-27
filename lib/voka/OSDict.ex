defmodule Voka.OSDict do
  import NimbleParsec

  def fra_to_spa(word) do
    search(word, "fd-fra-spa")
  end

  def spa_to_eng(word) do
    search(word, "fd-spa-eng")
  end

  def search(word, database) do
    {out, 0} = System.cmd("dict", ~w(--database #{database} --nocorrect #{word}))
    IO.puts([IO.ANSI.cyan(), out, IO.ANSI.default_color()])
    parse_result!(out)
  end

  spaces = repeat(string(" "))

  single_def =
    ignore(spaces)
    |> repeat(
      optional(
        ignore(string("["))
        |> utf8_string([{:not, ?]}], min: 1)
        |> ignore(string("] "))
      )
      |> utf8_string([{:not, ?,}, {:not, ?\n}], min: 1)
      |> optional(ignore(string(", ")))
    )
    |> reduce({:reduce_singles, []})
    |> ignore(string("\n"))

  num_def =
    ignore(spaces)
    |> ignore(ascii_string([?0..?9], min: 1))
    |> ignore(string("."))
    |> ignore(spaces)
    |> ignore(string("["))
    |> utf8_string([{:not, ?]}], min: 1)
    |> ignore(string("] "))
    |> utf8_string([{:not, ?\n}], min: 1)
    |> ignore(string("\n"))
    |> reduce({:to_num_def, []})

  multi_defs =
    times(num_def, min: 2)
    |> reduce({:reduce_multis, []})

  defp reduce_singles(words) do
    words =
      words
      |> Enum.map(&%{word: &1, context: nil})

    {:defs, words}
  end

  defp reduce_multis(words) do
    {:defs, words}
  end

  defp to_num_def([context, word]) do
    %{word: word, context: context}
  end

  result =
    ignore(ascii_string([?0..?9], 1))
    |> ignore(spaces)
    |> ignore(string("definition"))
    |> optional(ignore(string("s")))
    |> ignore(string(" found\n\n"))
    |> repeat(
      ignore(string("From "))
      |> ignore(utf8_string([{:not, ?\n}], min: 1))
      |> ignore(string("\n\n"))
      |> ignore(spaces)
      |> utf8_string([{:not, 32}], min: 1)
      |> ignore(spaces)
      |> ignore(string("/"))
      |> utf8_string([{:not, ?/}], min: 1)
      |> ignore(string("/"))
      |> ignore(spaces)
      |> ignore(string("<"))
      |> utf8_string([{:not, ?>}], min: 1)
      |> ignore(string(">"))
      |> ignore(string("\n"))
      |> choice([
        multi_defs,
        single_def
      ])
      |> optional(ignore(repeat(string("\n"))))
      |> reduce({:to_word, []})
    )

  defp to_word([word, phonetic, nature, {:defs, defs}]) do
    %{word: word, phonetic: phonetic, nature: nature, defs: defs}
  end

  defparsec(:parse_result, result, debug: true)

  def parse_result!(dict_output) do
    case parse_result(dict_output) do
      {:ok, acc, "", context, line, column} ->
        acc

      {:ok, acc, rest, context, line, column} ->
        rest |> IO.inspect(label: "rest")
        acc

      {:error, message, rest, context, line, column} ->
        raise ArgumentError, message: message
    end
  end
end
