defmodule VokaTest do
  use ExUnit.Case
  doctest Voka

  test "greets the world" do
    assert Voka.hello() == :world
  end
end
