defmodule Voka.OSDict do
  import NimbleParsec

  def fra_to_spa(word) do
    with {:ok, parsed} <- search(word, "fd-fra-spa") do
      cast_parsed(parsed)
    end
  end

  def spa_to_eng(word) do
    with {:ok, parsed} <- search(word, "fd-spa-eng") do
      cast_parsed(parsed)
    end
  end

  defp cast_parsed(results) do
    defs =
      Enum.map(results, fn {:word,
                            [
                              word,
                              {:phonetic, phonetic},
                              {:nature, nature}
                              | translations
                            ]} ->
        nature = unwrap(nature)
        translations = unwrap_defs(translations, nil, [])
        %{word: word, phonetic: unwrap(phonetic), nature: nature, translations: translations}
      end)

    {:ok, defs}
  end

  defp unwrap([item]), do: unwrap(item)
  defp unwrap(item), do: item

  defp unwrap_defs(list, context, acc) do
    list
    |> :lists.flatten()
    |> unwrap_def(context, acc)
    |> elem(1)
  end

  defp unwrap_def([], context, acc) do
    {context, acc}
  end

  defp unwrap_def([h | t], context, acc) do
    {context, acc} = unwrap_def(h, context, acc)
    unwrap_def(t, context, acc)
  end

  defp unwrap_def({:translation, t}, context, acc) do
    unwrap_def(t, context, acc)
  end

  defp unwrap_def({:trans, trans}, context, acc) do
    {context, [%{context: context, trans: trans} | acc]}
  end

  defp unwrap_def({:context, c}, _, acc) do
    {unwrap(c), acc}
  end

  # defp unwrap_defs([{:trans, [trans]} | rest], ctx, acc) do
  #   acc = [%{context: ctx, trans: trans} | acc]
  #   unwrap_defs(rest, ctx, acc)
  # end

  def search(word, database) do
    case System.cmd("dict", ~w(--database #{database} --nocorrect #{word})) do
      {out, 0} ->
        # IO.puts([IO.ANSI.cyan(), out, IO.ANSI.default_color()])

        case parse_result(out) do
          {:ok, acc, "", context, line, column} ->
            {:ok, acc}

          {:ok, acc, rest, context, line, column} ->
            rest |> IO.inspect(label: "rest")
            {:ok, acc}

          {:error, message, rest, context, line, column} ->
            {:error, message}
        end

      {out, 20} ->
        [IO.ANSI.yellow(), out, IO.ANSI.default_color()]

        {:error, {:no_def, word, database}}
    end
  end

  spaces = repeat(string(" "))

  trans_line =
    optional(
      ignore(string("["))
      |> utf8_string([{:not, ?]}], min: 1)
      |> ignore(string("] "))
      |> tag(:context)
    )
    |> repeat(
      utf8_string([{:not, ?,}, {:not, ?\n}], min: 1)
      |> optional(ignore(string(", ")))
      |> tag(:trans)
    )
    |> ignore(string("\n"))
    |> tag(:translation)

  single_def =
    ignore(spaces)
    |> concat(trans_line)

  num_def =
    ignore(spaces)
    |> ignore(ascii_string([?0..?9], min: 1))
    |> ignore(string("."))
    |> ignore(spaces)
    |> concat(single_def)

  multi_defs = times(num_def, min: 2)

  result =
    ignore(ascii_string([?0..?9], 1))
    |> ignore(spaces)
    |> ignore(string("definition"))
    |> optional(ignore(string("s")))
    |> ignore(string(" found\n\n"))
    |> ignore(repeat(string("\n")))
    |> repeat(
      ignore(string("From "))
      |> ignore(utf8_string([{:not, ?\n}], min: 1))
      |> ignore(repeat(string("\n")))
      |> ignore(spaces)
      |> utf8_string([{:not, 32}], min: 1)
      |> ignore(spaces)
      |> ignore(string("/"))
      |> concat(
        utf8_string([{:not, ?/}], min: 1)
        |> tag(:phonetic)
      )
      |> ignore(string("/"))
      |> ignore(spaces)
      |> optional(
        choice([
          ignore(string("<"))
          |> utf8_string([{:not, ?>}], min: 1)
          |> ignore(string(">")),
          empty
        ])
        |> tag(:nature)
      )
      |> ignore(repeat(string("\n")))
      |> choice([
        multi_defs,
        single_def
      ])
      |> optional(ignore(repeat(string("\n"))))
      |> tag(:word)
    )

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
