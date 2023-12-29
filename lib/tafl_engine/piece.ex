defmodule TaflEngine.Piece do
  alias __MODULE__

  @piece_types [:pawn, :king]
  @piece_colors [:black, :white]

  @enforce_keys [:type, :color]
  defstruct [:type, :color]

  def new(type, color) when type in @piece_types and color in @piece_colors do
    %Piece{type: type, color: color}
  end

  def new(_type, _color), do: {:error, :invalid_piece}
end
