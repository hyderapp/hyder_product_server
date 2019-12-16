defmodule HyderProductServerTest do
  use ExUnit.Case
  doctest HyderProductServer

  test "greets the world" do
    assert HyderProductServer.hello() == :world
  end
end
