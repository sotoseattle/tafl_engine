defmodule TaflEngine.Board do
  alias TaflEngine.Setup
  alias TaflEngine.Movement
  alias TaflEngine.Cell

  @king_only Setup.king_positions()

  def new() do
    Setup.new_board()
  end

  def move(board, from_coord, new_coord) do
    with {:ok, piece} <- Movement.there_is_a_piece_to_move(Map.get(board, from_coord)),
         {:ok, cell_path} <- Movement.there_is_a_path(from_coord, new_coord),
         :ok <- Movement.path_is_unblocked(board, cell_path),
         :ok <- Movement.destination_is_available(piece, new_coord) do
      board
      |> Map.delete(from_coord)
      |> Map.put(new_coord, piece)
    else
      err -> err
    end
  end

  @doc """
  remove from the board all the pawns that get killed
  """
  def remove_killed_pawns(board) do
    [whites, blacks] = [team(board, :white), team(board, :black)]

    dead =
      board
      |> Enum.filter(fn {k, v} ->
        Cell.surrounded?(k, enemies(whites, blacks, v.color), 2)
      end)
      |> Enum.map(fn {k, _} -> k end)

    remove_pawn(board, dead)
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
  def enemies(_whites, blacks, :white), do: Enum.concat(blacks, @king_only)
  def enemies(whites, _blacks, :black), do: Enum.concat(whites, @king_only)
end
