defmodule IslandsEngine.GameSupervisorTest do
  use ExUnit.Case
  alias IslandsEngine.GameSupervisor

  @game_name "Player 1 name"

  test "Game can be started" do
    assert {:ok, _game} = GameSupervisor.start_game(@game_name)
    GameSupervisor.stop_game(@game_name)
  end

  test "Creating a Game adds active children" do  
    %{:active => active} = Supervisor.count_children(GameSupervisor)
    assert active == 0

    {:ok, _game} = GameSupervisor.start_game(@game_name)

    %{:active => active} = Supervisor.count_children(GameSupervisor)
    assert active == 1

    :ok = GameSupervisor.stop_game(@game_name)
  end

  test "Stop existing game returns :ok" do
    GameSupervisor.start_game(@game_name)
    assert :ok == GameSupervisor.stop_game(@game_name)
  end

  test "Process is alive if we do not call stop_game" do
    {:ok, game} = GameSupervisor.start_game(@game_name)
    assert Process.alive?(game) == true

    GameSupervisor.stop_game(@game_name)
    assert Process.alive?(game) == false
  end

end

