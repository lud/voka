defmodule Voka.MixProject do
  use Mix.Project

  def project do
    [
      app: :voka,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Voka.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:jason, "~> 1.2"},
      {:tesla, "~> 1.4"},
      {:cubdb, "~> 1.0.0-rc.10"},
      {:nimble_parsec, "~> 1.1"},
      {:nimble_csv, "~> 1.1"},
      {:floki, "~> 0.31.0"},
      {:hackney, "~> 1.17"},
      {:ark, "~> 0.5.4"}
    ]
  end
end
