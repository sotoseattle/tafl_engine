defmodule BoardTest do
  use ExUnit.Case

  alias TaflEngine.Board
  alias TaflEngine.Cell
  alias TaflEngine.Piece

  setup do
    {:ok, pawn: Piece.new(:pawn, :royals)}
  end

  describe "movement of pieces on the board" do
    test "move cardinal points", %{pawn: p} do
      origin = Cell.cast(4, 4)
      destin = Cell.cast(4, 2)

      b = %{origin => p}

      {:ok, new_b} = Board.move(b, origin, destin, :royals)
      {:ok, new_b} = Board.move(new_b, destin, Cell.cast(1, 2), :royals)
      {:ok, new_b} = Board.move(new_b, Cell.cast(1, 2), Cell.cast(1, 4), :royals)
      {:ok, new_b} = Board.move(new_b, Cell.cast(1, 4), origin, :royals)

      assert new_b == b
    end

    test "blocking path", %{pawn: p} do
      origin = Cell.cast(1, 3)

      b = %{
        Cell.cast(3, 2) => p,
        Cell.cast(3, 3) => p,
        Cell.cast(3, 4) => p,
        origin => Piece.new(:pawn, :hunters)
      }

      assert Board.move(b, origin, origin, :hunters) == {:error, :no_move}
      assert Board.move(b, origin, Cell.cast(4, 3), :hunters) == {:error, :path_blocked}
      assert Board.move(b, origin, Cell.cast(2, 4), :hunters) == {:error, :diagonal_move}
      assert Board.move(b, origin, Cell.cast(1, 1), :hunters) == {:error, :pawn_not_allowed}
      assert Board.move(b, Cell.cast(1, 2), Cell.cast(1, 3), :hunters) == {:error, :empty_cell}
    end

    test "can pass over cells only for kings (as long as it doesn't land there)", %{pawn: p} do
      origin = Cell.cast(5, 8)
      destin = Cell.cast(5, 3)

      assert Board.move(%{origin => p}, origin, destin, :royals) == {:ok, %{destin => p}}

      assert Board.move(%{origin => p}, origin, Cell.cast(5, 5), :royals) ==
               {:error, :pawn_not_allowed}
    end
  end

  describe "killing pawns" do
    test "a hunters pawn between a king's landing and a royals one, dies", %{pawn: p} do
      b = %{Cell.cast(1, 2) => %{p | color: :hunters}, Cell.cast(1, 3) => p}

      assert Board.remove_killed_pawns(b) == {:ok, %{Cell.cast(1, 3) => p}}
    end

    test "a royals pawn between a king's landing and a royals one, lives", %{pawn: p} do
      b = %{Cell.cast(1, 2) => p, Cell.cast(1, 3) => p}

      assert Board.remove_killed_pawns(b) == {:ok, b}
    end

    test "a massacre (because we first find dead, and then we kill them)", %{pawn: p} do
      hunters_pawn = %{p | color: :hunters}

      b = %{
        Cell.cast(1, 2) => hunters_pawn,
        Cell.cast(1, 3) => p,
        Cell.cast(1, 4) => hunters_pawn
      }

      assert Board.remove_killed_pawns(b) == {:ok, %{Cell.cast(1, 4) => hunters_pawn}}
    end
  end
end
