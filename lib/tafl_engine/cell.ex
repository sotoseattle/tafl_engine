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
end
