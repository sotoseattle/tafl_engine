defmodule TaflEngine.Rules do
  alias __MODULE__

  defstruct state: :initialized

  def new() do
    %Rules{}
  end

  def check(%Rules{state: :initialized} = rules, :add_player) do
    {:ok, %Rules{rules | state: :players_set}}
  end

  def check(%Rules{state: :players_set} = rules, :start_game) do
    {:ok, %Rules{rules | state: :hunters_turn}}
  end

  def check(%Rules{state: :hunters_turn} = rules, {:move_piece, :hunters}) do
    {:ok, %Rules{rules | state: :royals_turn}}
  end

  def check(%Rules{state: :hunters_turn}, {:move_piece, _}), do: {:error, :hunters_turn}

  def check(%Rules{state: :hunters_turn} = rules, {:win_check, win_or_not}) do
    case win_or_not do
      :no_win -> {:ok, rules}
      :win -> {:ok, %Rules{rules | state: :game_over}}
    end
  end

  def check(%Rules{state: :royals_turn} = rules, {:move_piece, :royals}) do
    {:ok, %Rules{rules | state: :hunters_turn}}
  end

  def check(%Rules{state: :royals_turn}, {:move_piece, _}), do: {:error, :royals_turn}

  def check(%Rules{state: :royals_turn} = rules, {:win_check, win_or_not}) do
    case win_or_not do
      :no_win -> {:ok, rules}
      :win -> {:ok, %Rules{rules | state: :game_over}}
    end
  end

  def check(_state, action) do
    IO.inspect(action, label: "rules break action: ")
    {:error, :rules_break}
  end
end
