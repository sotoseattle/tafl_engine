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
    test "pawn sandwiched in 4 sides" do
      #      E
      #   E  P  E
      #      E
      enemies = Cell.expand_to_surrounding(Cell.cast(3, 3))

      assert Cell.sandwiched?(Cell.cast(3, 3), enemies, :one_side)
      assert Cell.sandwiched?(Cell.cast(3, 3), enemies, :two_sides)
    end

    test "pawn sandwiched in 2 sides" do
      #         E
      #   E  P  E
      #   E
      enemies = [Cell.cast(3, 4), Cell.cast(3, 2), Cell.cast(4, 4), Cell.cast(2, 2)]

      assert Cell.sandwiched?(Cell.cast(3, 3), enemies, :one_side)
      refute Cell.sandwiched?(Cell.cast(3, 3), enemies, :two_sides)
    end

    test "pawn sandwiched in no sides" do
      #         E
      #   E  P
      #   E     E
      enemies = [Cell.cast(2, 4), Cell.cast(3, 2), Cell.cast(4, 4), Cell.cast(2, 2)]

      refute Cell.sandwiched?(Cell.cast(3, 3), enemies, :one_side)
      refute Cell.sandwiched?(Cell.cast(3, 3), enemies, :two_sides)
    end

    test "pawn on edge not really sandwiched" do
      #      E
      #      P  E
      #   -  -  -
      enemies = [Cell.cast(1, 4), Cell.cast(2, 3)]

      refute Cell.sandwiched?(Cell.cast(1, 3), enemies, :one_side)
      refute Cell.sandwiched?(Cell.cast(1, 3), enemies, :two_sides)
    end
  end
end
