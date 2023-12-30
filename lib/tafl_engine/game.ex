defmodule TaflEngine.Game do
  alias TaflEngine.Rules
  alias TaflEngine.Board

  use GenServer

  def start_link(name) do
    GenServer.start_link(__MODULE__, name, [])
  end

  def add_new_player(game, name) when is_binary(name) do
    GenServer.call(game, {:add_player, name})
  end

  def change_sides(game) do
    GenServer.call(game, :flip_players)
  end

  def start_game(game) do
    GenServer.call(game, :start)
  end

  ######################################################

  def init(name) do
    royals = %{name: name}
    hunters = %{name: nil}
    {:ok, %{royals: royals, hunters: hunters, board: Board.new(), rules: %Rules{}}}
  end

  def handle_call({:add_player, name}, _from, state) do
    with {:ok, rules} <- Rules.check(state.rules, :add_player) do
      state
      |> update_hunters_name(name)
      |> update_rules(rules)
      |> reply_success(:ok)
    else
      :error -> {:reply, :error_adding_player, state}
    end
  end

  def handle_call(:flip_players, _from, state) do
    state
    |> flip_players()
    |> reply_success(:ok)
  end

  def handle_call(:start, _from, state) do
    with {:ok, rules} <- Rules.check(state.rules, :start_game) do
      state
      |> update_rules(rules)
      |> reply_success(:ok)
    else
      :error -> {:reply, :error_cannot_start_game, state}
    end
  end

  defp update_hunters_name(state, name), do: put_in(state.hunters.name, name)

  defp update_rules(state, rules), do: %{state | rules: rules}

  defp reply_success(state, reply), do: {:reply, reply, state}

  defp flip_players(state) do
    %{state | royals: state.hunters, hunters: state.royals}
  end

  defp gameboard(state), do: Map.get(state, :board)
end
