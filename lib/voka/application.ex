defmodule Voka.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # {CubDB, name: Voka.DB, data_dir: Path.join(File.cwd!(), "db")}
      # Starts a worker by calling: Voka.Worker.start_link(arg)
      # {Voka.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Voka.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
