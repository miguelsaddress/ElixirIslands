defmodule IslandsEngine.Guesses do
  @enforce_keys [:hits, :misses]
  defstruct [:hits, :misses]

  alias __MODULE__

  def new() do
    %Guesses{hits: MapSet.new(), misses: MapSet.new()}
  end

  # guesses = update_in(guesses.hits, &MapSet.put(&1, coordinate))
end