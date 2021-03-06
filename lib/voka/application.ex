defmodule Voka.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      VokaWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Voka.PubSub},
      # Start the Endpoint (http/https)
      VokaWeb.Endpoint,
      Voka.Store,
      {Task, fn -> Voka.run() |> Enum.to_list() |> Voka.Store.put_words() end}
      # Start a worker by calling: Voka.Worker.start_link(arg)
      # {Voka.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Voka.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    VokaWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
