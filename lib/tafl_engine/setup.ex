defmodule TaflEngine.Setup do
  alias TaflEngine.Cell
  alias TaflEngine.Piece

  def range() do
    1..9
  end

  def white_team() do
    [{4, 4}, {4, 5}, {4, 6}, {5, 4}, {5, 6}, {6, 4}, {6, 5}, {6, 6}]
    |> pawns(:white)
    |> Map.put(Cell.cast(5, 5), Piece.new(:king, :white))
  end

  def black_team() do
    [
      {1, 4},
      {1, 5},
      {1, 6},
      {2, 5},
      {9, 4},
      {9, 5},
      {9, 6},
      {8, 5},
      {4, 1},
      {5, 1},
      {6, 1},
      {5, 2},
      {4, 9},
      {5, 9},
      {6, 9},
      {5, 8}
    ]
    |> pawns(:black)
  end

  def new_board() do
    Map.merge(white_team(), black_team())
  end

  def king_positions() do
    [{1, 1}, {1, 9}, {9, 1}, {9, 9}, {5, 5}]
    |> Enum.map(fn {x, y} -> Cell.cast(x, y) end)
  end

  def pawns(coords, color) do
    coords
    |> Enum.map(fn {x, y} ->
      {Cell.cast(x, y), Piece.new(:pawn, color)}
    end)
    |> Map.new()
  end
end
