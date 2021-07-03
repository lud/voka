defmodule VokaWeb.Router do
  use VokaWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", VokaWeb do
    pipe_through :api
  end
end
