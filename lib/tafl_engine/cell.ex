defmodule TaflEngine.Cell do
  alias TaflEngine.Setup
  alias __MODULE__

  @board_range Setup.range()

  @enforce_keys [:row, :col]
  defstruct [:row, :col]

  def new(row, col) when row in @board_range and col in @board_range do
    {:ok, %Cell{row: row, col: col}}
  end

  def new(_row, _col), do: {:error, :invalid_coordinate}

  def cast(x, y) do
    case Cell.new(x, y) do
      {:ok, c} -> c
      err -> err
    end
  end

  def sandwiched?(cell, enemies, :one_side) do
    next_x(cell) |> find_attackers(enemies) |> Enum.count() == 2 ||
      next_y(cell) |> find_attackers(enemies) |> Enum.count() == 2
  end

  def sandwiched?(cell, enemies, :two_sides) do
    next_x(cell) |> find_attackers(enemies) |> Enum.count() == 2 &&
      next_y(cell) |> find_attackers(enemies) |> Enum.count() == 2
  end

  def sandwiched?(_, _, _), do: {:error, :no_sandwich_for_you}

  def next_x(%Cell{row: x, col: y}) do
    [Cell.new(x + 1, y), Cell.new(x - 1, y)] |> get_valid_cells()
  end

  def next_y(%Cell{row: x, col: y}) do
    [Cell.new(x, y + 1), Cell.new(x, y - 1)] |> get_valid_cells()
  end

  def expand_to_surrounding(c), do: next_x(c) ++ next_y(c)

  defp get_valid_cells(listo) do
    Enum.reduce(listo, [], fn {k, v}, acc ->
      if k == :ok, do: [v | acc], else: acc
    end)
  end

  def find_attackers(nearby_cells, occupied) do
    nearby_cells
    |> Enum.reduce([], fn a, acc ->
      if a in occupied, do: [a | acc], else: acc
    end)
  end
end
