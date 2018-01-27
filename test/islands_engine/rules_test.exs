defmodule IslandsEngine.RulesTest do
  use ExUnit.Case
  alias IslandsEngine.Rules

  test "default initial state is :initialized" do
    rules = Rules.new
    assert rules.state == :initialized
  end

  test "check/2 returns error for unexpected state" do
    rules = %Rules{ Rules.new | state: :wrong }
    assert Rules.check(rules, :an_action) === :error
  end

  test "check/2 returns can transition from :initialized to :players_set with :add_player action" do
    rules = Rules.new
    {:ok, rules} = Rules.check(rules, :add_player)
    assert rules.state == :players_set
  end

  test "check/2 cannot receive from :initialized other than :add_player action" do
    rules = Rules.new
    assert :error == Rules.check(rules, :something)
    assert rules.state == :initialized
  end

  test "check/2 can accept from :players_set the action :position_islands IFF player islands are not yet set" do
    expected_rules = %Rules{
      player1: :islands_not_set,
      player2: :islands_not_set,
      state: :players_set
    }

    rules = %Rules{ Rules.new | state: :players_set }

    {:ok, rules} = Rules.check(rules, {:position_islands, :player1})
    assert rules == expected_rules

    {:ok, rules} = Rules.check(rules, {:position_islands, :player2})
    assert rules == expected_rules
  end

  test "check/2 returns :error from :players_set when action given is :position_islands IFF player islands are set" do
    rules = %Rules{ Rules.new | state: :players_set, player1: :islands_set }

    :error = Rules.check(rules, {:position_islands, :player1})
    {:ok, %Rules{}} = Rules.check(rules, {:position_islands, :player2})
  end

  test "check/2 can transition from :players_set to :set_islands for a player" do
    rules = %Rules{ Rules.new | state: :players_set }
    {:ok, rules} = Rules.check(rules, {:set_islands, :player1})
    assert rules.state == :players_set

    rules = %Rules{ Rules.new | state: :players_set}
    {:ok, rules} = Rules.check(rules, {:set_islands, :player2})
    assert rules.state == :players_set
  end

  test "check/2 transitions to :player1_turn when both players have set their islands" do
    rules = %Rules{ Rules.new | state: :players_set }

    {:ok, rules} = Rules.check(rules, {:set_islands, :player1})
    {:ok, rules} = Rules.check(rules, {:set_islands, :player2})

    assert rules.player1 == :islands_set
    assert rules.player2 == :islands_set
    assert rules.state == :player1_turn
  end

  test "check/2 returns :error if a player tries to position islands once all players have set them" do
    rules = %Rules{ Rules.new | state: :players_set, player1: :islands_set, player2: :islands_set }

    :error = Rules.check(rules, {:position_islands, :player1})
    :error = Rules.check(rules, {:position_islands, :player2})
  end

  test "check/2 returns :error if state is :player1_turn and action is not :guess_coordinate" do
    rules = %Rules{ Rules.new | state: :player1_turn, player1: :islands_set, player2: :islands_set }

    :error = Rules.check(rules, :something)
    :error = Rules.check(rules, :add_player)
    :error = Rules.check(rules, {:something, :player2})
    :error = Rules.check(rules, {:position_islands, :player2})
    :error = Rules.check(rules, {:set_islands, :player2})
  end

  test "check/2 can transition from :player1_turn to :player2_turn after player1 :guess_coordinate is given" do
    rules = %Rules{ Rules.new | state: :player1_turn, player1: :islands_set, player2: :islands_set }
    {:ok, rules} = Rules.check(rules, {:guess_coordinate, :player1})
    assert rules.state == :player2_turn
  end

  test "check/2 returns :error if another playertries to play when state is :player1_turn" do
    rules = %Rules{ Rules.new | state: :player1_turn, player1: :islands_set, player2: :islands_set }
    :error = Rules.check(rules, {:guess_coordinate, :player2})
    assert rules.state == :player1_turn
  end

  test "check/2 keeps rules intact when move is a :no_win" do
    original_rules = %Rules{ Rules.new | state: :player1_turn }
    {:ok, rules} = Rules.check(original_rules, {:win_check, :no_win})
    assert original_rules == rules
  end

  test "check/2 transitions to :game_over when move is a :win" do
    rules = %Rules{ Rules.new | state: :player1_turn }
    {:ok, rules} = Rules.check(rules, {:win_check, :win})
    assert rules.state == :game_over

    rules = %Rules{ Rules.new | state: :player2_turn }
    {:ok, rules} = Rules.check(rules, {:win_check, :win})
    assert rules.state == :game_over
  end

  test "players should be able to alternate rounds until game_over" do
    rules = %Rules{ Rules.new | state: :player1_turn }

    :error = Rules.check(rules, {:guess_coordinate, :player2})
    {:ok, rules} = Rules.check(rules, {:guess_coordinate, :player1})

    :error = Rules.check(rules, {:guess_coordinate, :player1})
    {:ok, rules} = Rules.check(rules, {:guess_coordinate, :player2})

    {:ok, rules} = Rules.check(rules, {:win_check, :no_win})
    assert rules.state == :player1_turn

    {:ok, rules} = Rules.check(rules, {:win_check, :win})
    assert rules.state == :game_over

    :error = Rules.check(rules, :some_action)
  end

end
