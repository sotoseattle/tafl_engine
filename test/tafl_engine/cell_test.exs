defmodule CellTest do
  use ExUnit.Case

  alias TaflEngine.Cell

  test "basic creation of cells" do
    assert Cell.new(0, 0) == {:error, :invalid_coordinate}

    assert {:ok, _} = Cell.new(1, 1)

    assert Cell.new(-1, 1) == {:error, :invalid_coordinate}

    assert Cell.new(1, 10) == {:error, :invalid_coordinate}

    assert Cell.new(1, 1.2) == {:error, :invalid_coordinate}

    assert {:ok, _} = Cell.new(1, 9)
    assert {:ok, _} = Cell.new(9, 9)
  end

  describe "find surrounding cells " do
    test "easy case" do
      assert Cell.expand_to_surrounding(Cell.cast(3, 3)) --
               [Cell.cast(3, 4), Cell.cast(3, 2), Cell.cast(4, 3), Cell.cast(2, 3)] ==
               []
    end

    test "near edge" do
      assert Cell.expand_to_surrounding(Cell.cast(1, 3)) --
               [Cell.cast(1, 4), Cell.cast(1, 2), Cell.cast(2, 3)] ==
               []
    end
  end

  describe "find if cell will die" do
    test "pawn surrounded in 4 sides" do
      enemies = Cell.expand_to_surrounding(Cell.cast(3, 3))

      assert Cell.surrounded?(Cell.cast(3, 3), enemies, 1)
      assert Cell.surrounded?(Cell.cast(3, 3), enemies, 2)
      assert Cell.surrounded?(Cell.cast(3, 3), enemies, 3)
      assert Cell.surrounded?(Cell.cast(3, 3), enemies, 4)
      refute Cell.surrounded?(Cell.cast(3, 3), enemies, 5)
    end

    test "pawn surrounded in 2 sides" do
      enemies = [Cell.cast(3, 4), Cell.cast(3, 2), Cell.cast(4, 4), Cell.cast(2, 2)]

      assert Cell.surrounded?(Cell.cast(3, 3), enemies, 1)
      assert Cell.surrounded?(Cell.cast(3, 3), enemies, 2)
      refute Cell.surrounded?(Cell.cast(3, 3), enemies, 3)
      refute Cell.surrounded?(Cell.cast(3, 3), enemies, 4)
    end

    test "pawn surrounded in 1 sides" do
      enemies = [Cell.cast(2, 4), Cell.cast(3, 2), Cell.cast(4, 4), Cell.cast(2, 2)]

      assert Cell.surrounded?(Cell.cast(3, 3), enemies, 1)
      refute Cell.surrounded?(Cell.cast(3, 3), enemies, 2)
      refute Cell.surrounded?(Cell.cast(3, 3), enemies, 3)
      refute Cell.surrounded?(Cell.cast(3, 3), enemies, 4)
    end

    test "pawn on edge surrounded in 2 sides" do
      enemies = [Cell.cast(1, 4), Cell.cast(2, 3)]

      assert Cell.surrounded?(Cell.cast(1, 3), enemies, 1)
      assert Cell.surrounded?(Cell.cast(1, 3), enemies, 2)
      refute Cell.surrounded?(Cell.cast(1, 3), enemies, 3)
      refute Cell.surrounded?(Cell.cast(1, 3), enemies, 4)
    end
  end
end
