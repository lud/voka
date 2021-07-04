defmodule VokaWeb.PageController do
  use VokaWeb, :controller

  def index(conn, _params) do
    words = Voka.Store.get_words()

    render(conn, "index.html", words: words)
  end
end
