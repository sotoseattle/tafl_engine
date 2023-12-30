defmodule TaflEngine.Movement do
  alias TaflEngine.Cell
  alias TaflEngine.Setup
  alias TaflEngine.Piece
  alias TaflEngine.Cell

  @king_only Setup.king_positions()

  def there_is_a_piece_to_move(%Piece{} = p), do: {:ok, p}

  def there_is_a_piece_to_move(nil), do: {:error, :empty_cell}

  def piece_belongs_to_player(%Piece{color: player}, player), do: :ok

  def piece_belongs_to_player(_, _), do: {:error, :piece_does_not_belong_to_player}

  def there_is_a_path(origin, origin), do: {:error, :no_move}

  def there_is_a_path(%Cell{row: r, col: c1}, %Cell{row: r, col: c2}) do
    hops = abs(c2 - c1)
    delta = if c2 >= c1, do: 1, else: -1

    path = 1..hops |> Enum.map(fn i -> Cell.cast(r, c1 + i * delta) end)

    {:ok, path}
  end

  def there_is_a_path(%Cell{row: r1, col: c}, %Cell{row: r2, col: c}) do
    hops = abs(r2 - r1)
    delta = if r2 >= r1, do: 1, else: -1

    path = 1..hops |> Enum.map(fn i -> Cell.cast(r1 + i * delta, c) end)

    {:ok, path}
  end

  def there_is_a_path(_, _), do: {:error, :diagonal_move}

  def path_is_unblocked(board, cell_path) do
    occupied = Map.keys(board)

    if Enum.any?(cell_path, &(&1 in occupied)) do
      {:error, :path_blocked}
    else
      :ok
    end
  end

  def destination_is_available(%Piece{type: :king}, cell)
      when cell in @king_only,
      do: :ok

  def destination_is_available(_piece, cell) when cell in @king_only,
    do: {:error, :pawn_not_allowed}

  def destination_is_available(_, _), do: :ok
end
