defmodule TaflEngineTest do
  use ExUnit.Case
  doctest TaflEngine

  test "greets the world" do
    assert TaflEngine.hello() == :world
  end
end
