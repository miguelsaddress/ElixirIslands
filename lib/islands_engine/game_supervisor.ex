defmodule IslandsEngine.GameSupervisor do
  use Supervisor
  
  alias IslandsEngine.Game

  def start_link(_options) do
    # It will produce a call to init(:ok). The local name of 
    # the supervisor will be IslandsEngine.GameSupervisor
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def start_game(name) do
    # calls Game.start_link(name)
    Supervisor.start_child(__MODULE__, [name])
  end

  def stop_game(name) do
    Supervisor.terminate_child(__MODULE__, pid_for_name(name))
  end

  def init(:ok) do
    # Will supervise Game with the simple one for one strategy
    Supervisor.init([Game], strategy: :simple_one_for_one)
  end

  defp pid_for_name(name) do
    name
    |> Game.via_tuple()
    |> GenServer.whereis()
  end
end