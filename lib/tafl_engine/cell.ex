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

  def surrounded?(cell, occupied, sides) do
    cell
    |> expand_to_surrounding()
    |> Enum.reduce([], fn a, acc ->
      if a in occupied, do: [a | acc], else: acc
    end)
    |> Enum.count() >=
      sides
  end

  def expand_to_surrounding(%Cell{row: x, col: y}) do
    [
      Cell.new(x + 1, y),
      Cell.new(x - 1, y),
      Cell.new(x, y + 1),
      Cell.new(x, y - 1)
    ]
    |> Enum.reduce([], fn {k, v}, acc ->
      if k == :ok, do: [v | acc], else: acc
    end)
  end
end
