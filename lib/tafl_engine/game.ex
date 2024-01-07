defmodule TaflEngine.Game do
  alias TaflEngine.Rules
  alias TaflEngine.Cell
  alias TaflEngine.Board

  use GenServer, start: {__MODULE__, :start_link, []}, restart: :transient

  @players [:hunters, :royals]
  @timeout 60 * 60 * 24 * 1000

  def via_tuple(name) do
    {:via, Registry, {Registry.Game, name}}
  end

  def start_link(name) when is_binary(name) do
    GenServer.start_link(__MODULE__, name, name: via_tuple(name))
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

  def get_state(game) do
    :sys.get_state(game)
  end

  ######################################################

  def init(name) do
    send(self(), {:set_state, name})

    {:ok, fresh_state(name)}
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

  def handle_info({:set_state, name}, _state) do
    state =
      case :ets.lookup(:game_state, name) do
        [] -> fresh_state(name)
        [{_key, state}] -> state
      end

    :ets.insert(:game_state, {name, state})

    {:noreply, state, @timeout}
  end

  def handle_info(:timeout, state) do
    {:stop, {:shutdown, :timeout}, state}
  end

  def terminate({:shutdown, :timeout}, state) do
    :ets.delete(:game_state, state.owner)
    :ok
  end

  def terminate(_, _), do: :ok

  ######################################################

  defp update_hunters_name(state, name), do: put_in(state.hunters, name)

  defp update_rules(state, rules), do: %{state | rules: rules}

  defp update_board(state, board), do: %{state | board: board}

  defp reply_success(state, reply) do
    :ets.insert(:game_state, {state.owner, state})
    {:reply, reply, state, @timeout}
  end

  defp flip_players(state) do
    %{state | royals: state.hunters, hunters: state.royals}
  end

  defp fresh_state(name) do
    %{owner: name, royals: name, hunters: nil, board: Board.new(), rules: %Rules{}}
  end

  # defp gameboard(state), do: Map.get(state, :board)

  # defp opponent(:royals), do: :hunters
  # defp opponent(:hunters), do: :royals
end
