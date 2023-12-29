defmodule CellTest do
  use ExUnit.Case

  alias TaflEngine.Cell

  test "..." do
    assert Cell.new(0, 0) == {:error, :invalid_coordinate}

    assert {:ok, _} = Cell.new(1, 1)

    assert Cell.new(-1, 1) == {:error, :invalid_coordinate}

    assert Cell.new(1, 10) == {:error, :invalid_coordinate}

    assert Cell.new(1, 1.2) == {:error, :invalid_coordinate}

    assert {:ok, _} = Cell.new(1, 9)
    assert {:ok, _} = Cell.new(9, 9)
  end
end
