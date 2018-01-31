defmodule IslandsEngine.Game do
  use GenServer
  alias IslandsEngine.{Board, Guesses, Rules}

  def start_link(name) do
    state = %{
      player1: %{name: name, board: Board.new(), guesses: Guesses.new()},
      player2: %{name: nil,  board: Board.new(), guesses: Guesses.new()},
      rules: Rules.new()
    }
    GenServer.start_link(__MODULE__, state)
  end

  def add_player(game, name) when is_binary(name) do
    GenServer.call(game, {:add_player, name})
  end

  def handle_call({:add_player, name}, _from, state_data) do
    with {:ok, rules} <- Rules.check(state_data.rules, :add_player)
    do
      state_data
      |> update_player2_name(name)
      |> update_rules(rules)
      |> reply_success(:ok)
    else
      :error -> {:reply, :error, state_data}
    end
  end

  defp update_player2_name(state_data, name), do: put_in(state_data.player2.name, name)
  defp update_rules(state_data, rules), do: %{state_data | rules: rules}
  defp reply_success(state_data, reply), do: {:reply, reply, state_data}

end
