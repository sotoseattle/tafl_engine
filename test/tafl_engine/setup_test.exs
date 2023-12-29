defmodule SetupTest do
  use ExUnit.Case

  alias TaflEngine.Setup
  alias TaflEngine.Cell
  alias TaflEngine.Piece

  test "setup is correct and full of cells, pieces" do
    b = Setup.new_board()
    refute b == %{}
    assert b |> Enum.all?(fn {%Cell{} = k, %Piece{} = v} -> {k, v} end) == true
  end

  test "setup fills the board with 9 whites and 16 black pieces" do
    b = Setup.new_board()
    assert b |> Enum.filter(fn {_, v} -> v.color == :white end) |> Enum.count() == 9
    assert b |> Enum.filter(fn {_, v} -> v.color == :black end) |> Enum.count() == 16
  end

  test "setup places only one king in the board" do
    list = Setup.new_board() |> Enum.filter(fn {_, v} -> v.type == :king end)
    assert Enum.count(list) == 1

    {_, k} = List.first(list)
    assert k.color == :white
  end
end
