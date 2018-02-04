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

  test "position_islands/5 adds island to player's board as expected" do
    {:ok, game} = Game.start_link("Player1 name")
    Game.add_player(game, "Player2 name")
    Game.position_island(game, :player1, :square, 1, 1)
    state_data = :sys.get_state(game)
    assert Map.has_key?(state_data.player1.board, :square)
  end

  test "position_island/5 returns {:error, :invalid_coordinate} for a coordinate out of the board" do
    {:ok, game} = Game.start_link("Player1 name")
    Game.add_player(game, "Player2 name")
    assert Game.position_island(game, :player1, :dot, 12, 1) == {:error, :invalid_coordinate}
  end

  test "position_island/5 returns {:error, :invalid_coordinate} for a coordinate inside of the board but the island would exceed the board" do
    {:ok, game} = Game.start_link("Player1 name")
    Game.add_player(game, "Player2 name")
    assert Game.position_island(game, :player1, :square, 10, 0) == {:error, :invalid_coordinate}
  end

  test "position_island/5 returns {:error, :invalid_island_type} for an invalid island type" do
    {:ok, game} = Game.start_link("Player1 name")
    Game.add_player(game, "Player2 name")
    assert Game.position_island(game, :player1, :wrong, 1, 1) == {:error, :invalid_island_type}
  end

  test "set_islands/2 works when all islands have already been set for the player" do
    {:ok, game} = Game.start_link("Player1 name")
    Game.add_player(game, "Player2 name")
    # position all islands
    # [x][x][ ][ ][ ][ ][ ][ ][ ][ ]
    # [x][x][ ][x][ ][ ][ ][ ][x][x]
    # [ ][ ][ ][ ][ ][ ][ ][ ][ ][x]
    # [ ][ ][ ][x][ ][ ][ ][ ][x][x]
    # [ ][ ][ ][x][ ][ ][ ][ ][ ][ ]
    # [ ][ ][ ][x][x][ ][ ][ ][ ][ ]
    # [ ][ ][ ][ ][ ][ ][ ][ ][ ][ ]
    # [ ][ ][ ][ ][ ][x][x][ ][ ][ ]
    # [ ][ ][ ][ ][x][x][ ][ ][ ][ ]
    # [ ][ ][ ][ ][ ][ ][ ][ ][ ][ ]

    Game.position_island(game, :player1, :square, 1, 1)
    Game.position_island(game, :player1, :dot, 2, 4)
    Game.position_island(game, :player1, :atoll, 2, 9)
    Game.position_island(game, :player1, :l_shape, 4, 4)
    Game.position_island(game, :player1, :s_shape, 8, 6)

    assert :ok == Game.set_islands(game, :player1)
  end

  test "set_islands/2 returns :error when not all islands have already been set for the player" do
    {:ok, game} = Game.start_link("Player1 name")
    Game.add_player(game, "Player2 name")
    assert {:error, :not_all_islands_positioned} == Game.set_islands(game, :player1)
  end

  test "guess_coordinate/4 returns error when its not players turn" do
    {:ok, game} = Game.start_link("Player1 name")
    Game.add_player(game, "Player2 name")
    # advance state to player1_turn
    :sys.replace_state(game, fn state_data ->
      %{state_data | rules: %Rules{state: :player1_turn}}
    end)
    assert Game.guess_coordinate(game, :player2, 1, 1) == :error
  end

  test "guess_coordinate/4 returns {:miss, :none, :no_win} when its a miss" do
    {:ok, game} = Game.start_link("Player1 name")
    Game.add_player(game, "Player2 name")
    Game.position_island(game, :player1, :dot, 1, 1)
    Game.position_island(game, :player2, :square, 1, 1)
    # advance state to player1_turn
    :sys.replace_state(game, fn state_data ->
      %{state_data | rules: %Rules{state: :player1_turn}}
    end)

    assert Game.guess_coordinate(game, :player1, 6, 6) == {:miss, :none, :no_win}
  end

  test "guess_coordinate/4 returns {:hit, :none, :no_win} when its a hit but island is not forested" do
    {:ok, game} = Game.start_link("Player1 name")
    Game.add_player(game, "Player2 name")
    Game.position_island(game, :player1, :dot, 1, 1)
    Game.position_island(game, :player2, :square, 1, 1)
    # advance state to player1_turn
    :sys.replace_state(game, fn state_data ->
      %{state_data | rules: %Rules{state: :player1_turn}}
    end)

    assert Game.guess_coordinate(game, :player1, 1, 1) == {:hit, :none, :no_win}
  end

  test "guess_coordinate/4 returns {:hit, _island_type, :no_win} when its a hit, island is forested but its not a win" do
    {:ok, game} = Game.start_link("Player1 name")
    Game.add_player(game, "Player2 name")
    Game.position_island(game, :player1, :dot, 1, 1)
    Game.position_island(game, :player1, :square, 4, 4)
    Game.position_island(game, :player2, :square, 1, 1)
    # advance state to player1_turn
    :sys.replace_state(game, fn state_data ->
      %{state_data | rules: %Rules{state: :player2_turn}}
    end)

    assert Game.guess_coordinate(game, :player2, 1, 1) == {:hit, :dot, :no_win} #square island remains
  end

  test "guess_coordinate/4 returns {:hit, _island_type, :win} when its a hit, island is forested and its a win" do
    {:ok, game} = Game.start_link("Player1 name")
    Game.add_player(game, "Player2 name")
    Game.position_island(game, :player1, :dot, 1, 1)
    Game.position_island(game, :player2, :square, 1, 1)
    # advance state to player1_turn
    :sys.replace_state(game, fn state_data ->
      %{state_data | rules: %Rules{state: :player2_turn}}
    end)

    assert Game.guess_coordinate(game, :player2, 1, 1) == {:hit, :dot, :win}
    # and state should be now :game_over because one player won
    state_data = :sys.get_state(game)
    assert state_data.rules.state == :game_over
  end
end
