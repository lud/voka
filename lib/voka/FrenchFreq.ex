defmodule Voka.FrenchFreq do
  NimbleCSV.define(__MODULE__.Parser, separator: ",", escape: "\"")

  @csv_source Path.join([File.cwd!(), "priv", "french-freq.csv"])

  def get_most_used_words(max \\ 999_999_999_999) do
    @csv_source
    |> IO.inspect(label: "value")
    |> File.stream!()
    |> __MODULE__.Parser.parse_stream()
    |> Stream.map(fn [nature, freq_str, word] ->
      {nature, String.to_integer(freq_str), word}
    end)
    |> Enum.sort_by(fn {_, freq, _} -> freq * -1 end)
    |> Enum.take(max)
    |> Enum.map(&elem(&1, 2))
  end
end
