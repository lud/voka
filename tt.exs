# Voka.Deepl.trans_word("retourner", "FR", "ES")
# |> IO.inspect(label: "translated")

~w(bonjour aimer les sushi manger beaucoup)
|> Enum.map(fn w ->
  Voka.OSDict.fra_to_spa(w)
  |> IO.inspect(label: w)
end)
