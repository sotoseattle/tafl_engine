defmodule GameTest do
  use ExUnit.Case

  alias TaflEngine.Game

  test "run through basic case" do
    {:ok, g} = Game.start_link("javier")
    assert get_rules_state(g) == :initialized

    Game.add_new_player(g, "pepe")
    assert get_rules_state(g) == :players_set

    Game.start_game(g)
    assert get_rules_state(g) == :hunters_turn

    assert Game.move_piece(g, :royals, {2, 2}, {3, 3}) ==
             {:error, :hunters_turn}

    assert Game.move_piece(g, :hunters, {2, 2}, {2, 2}) ==
             {:error, :empty_cell}

    assert Game.move_piece(g, :hunters, {5, 5}, {5, 5}) ==
             {:error, :piece_does_not_belong_to_player}

    assert Game.move_piece(g, :hunters, {9, 5}, {9, 5}) ==
             {:error, :no_move}

    assert Game.move_piece(g, :hunters, {9, 5}, {9, 6}) ==
             {:error, :path_blocked}

    assert Game.move_piece(g, :hunters, {9, 6}, {9, 9}) ==
             {:error, :pawn_not_allowed}

    assert Game.move_piece(g, :hunters, {9, 6}, {9, 8}) == :ok
    assert get_rules_state(g) == :royals_turn
  end

  defp get_rules_state(g) do
    g |> :sys.get_state() |> Map.get(:rules) |> Map.get(:state)
  end
end
