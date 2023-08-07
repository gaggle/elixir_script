defmodule ElixirScriptTest do
  use ExUnit.Case
  doctest ElixirScript

  test "greets the world" do
    assert ElixirScript.hello() == :world
  end
end
