defmodule IslandsEngine.GameTest do
  use ExUnit.Case
  alias IslandsEngine.{Game, Rules, Guesses}

  test "start_link/1 creates expecte state with player1 name set" do
    {:ok, game} = Game.start_link("Player1 name")
    state_data = :sys.get_state(game)
    assert state_data.player1.name == "Player1 name"
    assert 0 == Map.size(state_data.player1.board)
    assert %Guesses{} = state_data.player1.guesses

    assert state_data.player2.name == nil
    assert 0 == Map.size(state_data.player2.board)
    assert %Guesses{} = state_data.player2.guesses

    assert %Rules{} = state_data.rules
  end

  test "add_player/2 sets player 2 name and updates rules" do
    {:ok, game} = Game.start_link("Player1 name")
    :ok = Game.add_player(game, "Player2 name")
    state_data = :sys.get_state(game)

    assert state_data.player2.name == "Player2 name"
    assert state_data.rules.state == :players_set
  end

  test "add_player/2 fails when rules do not allow it" do
    {:ok, game} = Game.start_link("Player1 name")

    :sys.replace_state(game, fn(state_data) ->
      %{state_data | rules: %Rules{state: :players_set}}
    end)

    :error = Game.add_player(game, "Player2 name")
  end

end
