defmodule Voka.ResultCsv do
  NimbleCSV.define(__MODULE__.Parser,
    separator: ",",
    escape: "\"",
    reserved: [",", "\"", "/", "\n"]
  )

  @csv_source Path.join([File.cwd!(), "_build", "result.csv"])

  @header ~w(word es es_p ca ca_p)

  def stream_to_file(data_stream) do
    words =
      data_stream
      |> Stream.map(fn %{ca: ca, ca_p: ca_p, es: es, es_p: es_p, word: word} ->
        [word, es, es_p, ca, ca_p]
      end)

    [@header]
    |> Stream.concat(words)
    |> __MODULE__.Parser.dump_to_stream()
    |> Stream.into(File.stream!(@csv_source, [:write, :utf8]))
  end
end
