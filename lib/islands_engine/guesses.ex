defmodule IslandsEngine.Guesses do
  @enforce_keys [:hits, :misses]
  defstruct [:hits, :misses]

  alias IslandsEngine.{Guesses, Coordinate}

  def new() do
    %Guesses{hits: MapSet.new(), misses: MapSet.new()}
  end

  def add(%Guesses{} = guesses, :hit, %Coordinate{} = coordinate) do
    update_in(guesses.hits, &MapSet.put(&1, coordinate))
  end

  def add(%Guesses{} = guesses, :miss, %Coordinate{} = coordinate) do
    update_in(guesses.misses, &MapSet.put(&1, coordinate))
  end

end