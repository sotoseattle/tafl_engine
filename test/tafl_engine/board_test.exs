defmodule BoardTest do
  use ExUnit.Case

  alias TaflEngine.Board
  alias TaflEngine.Cell
  alias TaflEngine.Piece

  setup do
    {:ok, pawn: Piece.new(:pawn, :white)}
  end

  test "move cardinal points", %{pawn: p} do
    origin = Cell.cast(4, 4)
    destin = Cell.cast(4, 2)

    b = %{origin => p}

    new_b =
      b
      |> Board.move(origin, destin)
      |> Board.move(destin, Cell.cast(1, 2))
      |> Board.move(Cell.cast(1, 2), Cell.cast(1, 4))
      |> Board.move(Cell.cast(1, 4), origin)

    assert new_b == b
  end

  test "blocking path", %{pawn: p} do
    origin = Cell.cast(1, 3)

    b = %{
      Cell.cast(3, 2) => p,
      Cell.cast(3, 3) => p,
      Cell.cast(3, 4) => p,
      origin => Piece.new(:pawn, :black)
    }

    assert Board.move(b, origin, origin) == {:error, :no_move}
    assert Board.move(b, origin, Cell.cast(4, 3)) == {:error, :path_blocked}
    assert Board.move(b, origin, Cell.cast(2, 4)) == {:error, :diagonal_move}
    assert Board.move(b, origin, Cell.cast(1, 1)) == {:error, :pawn_not_allowed}
    assert Board.move(b, Cell.cast(1, 2), Cell.cast(1, 3)) == {:error, :empty_cell}
  end

  test "can pass over cells only for kings (as long as it doesn't land there)", %{pawn: p} do
    origin = Cell.cast(5, 8)
    destin = Cell.cast(5, 3)

    assert Board.move(%{origin => p}, origin, destin) == %{destin => p}
    assert Board.move(%{origin => p}, origin, Cell.cast(5, 5)) == {:error, :pawn_not_allowed}
  end
end
