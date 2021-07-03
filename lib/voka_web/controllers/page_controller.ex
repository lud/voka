defmodule VokaWeb.PageController do
  use VokaWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
