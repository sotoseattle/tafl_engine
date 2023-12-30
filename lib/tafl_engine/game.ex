defmodule TaflEngine.Game do
  alias TaflEngine.Rules
  alias TaflEngine.Cell
  alias TaflEngine.Board

  use GenServer

  @players [:hunters, :royals]

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

  def move_piece(game, player, {r1, c1} = _from, {r2, c2} = _to) when player in @players do
    GenServer.call(game, {:move, player, {r1, c1}, {r2, c2}})
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
    end
  end

  def handle_call({:move, player, {r1, c1}, {r2, c2}}, _from, state) do
    with {:ok, rules} <- Rules.check(state.rules, {:move_piece, player}),
         {:ok, from_coord} <- Cell.new(r1, c1),
         {:ok, new_coord} <- Cell.new(r2, c2),
         {:ok, board} <- Board.move(state.board, from_coord, new_coord, player) do
      state
      |> update_board(board)
      |> update_rules(rules)
      |> reply_success(:ok)
    else
      error -> {:reply, error, state}
    end
  end

  defp update_hunters_name(state, name), do: put_in(state.hunters.name, name)

  defp update_rules(state, rules), do: %{state | rules: rules}

  defp update_board(state, board), do: %{state | board: board}

  defp reply_success(state, reply), do: {:reply, reply, state}

  defp flip_players(state) do
    %{state | royals: state.hunters, hunters: state.royals}
  end

  # defp gameboard(state), do: Map.get(state, :board)

  # defp opponent(:royals), do: :hunters
  # defp opponent(:hunters), do: :royals
end
