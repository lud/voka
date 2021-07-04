defmodule Voka.Store do
  use Agent

  @server __MODULE__

  def start_link(_) do
    Agent.start_link(fn -> [] end, name: @server)
  end

  def put_words(words) do
    Agent.update(@server, fn _ -> words end)
  end

  def get_words() do
    Agent.get(@server, & &1)
  end
end
