defmodule TaflEngine.Board do
  alias TaflEngine.Setup
  alias TaflEngine.Movement
  alias TaflEngine.Cell

  @king_only Setup.king_positions()

  def new() do
    Setup.new_board()
  end

  def move(board, from_coord, new_coord, player) do
    with {:ok, piece} <- Movement.there_is_a_piece_to_move(Map.get(board, from_coord)),
         :ok <- Movement.piece_belongs_to_player(piece, player),
         {:ok, cell_path} <- Movement.there_is_a_path(from_coord, new_coord),
         :ok <- Movement.path_is_unblocked(board, cell_path),
         :ok <- Movement.destination_is_available(piece, new_coord) do
      new_board =
        board
        |> Map.delete(from_coord)
        |> Map.put(new_coord, piece)

      {:ok, new_board}
    else
      err -> err
    end
  end

  @doc """
  remove from the board all the pawns that get killed
  """
  def remove_killed_pawns(board) do
    [royals, hunters] = [team(board, :royals), team(board, :hunters)]

    dead =
      board
      |> Enum.filter(fn {k, v} ->
        Cell.sandwiched?(k, enemies(royals, hunters, v.color), :one_side)
      end)
      |> Enum.map(fn {k, _} -> k end)

    {:ok, remove_pawn(board, dead)}
  end

  defp remove_pawn(board, []), do: board

  defp remove_pawn(board, [c | cells]) do
    remove_pawn(Map.delete(board, c), cells)
  end

  @doc """
  get all the pieces on the board of a color
  """
  def team(board, color) do
    board
    |> Enum.filter(fn {_k, v} -> v.color == color end)
    |> Enum.map(fn {k, _} -> k end)
  end

  @doc """
  get the opposing pieces and those king landings that act as enemy
  """
  def enemies(_royals, hunters, :royals), do: Enum.concat(hunters, @king_only)
  def enemies(royals, _hunters, :hunters), do: Enum.concat(royals, @king_only)
end
