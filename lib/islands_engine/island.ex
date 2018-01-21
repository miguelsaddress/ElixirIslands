defmodule IslandsEngine.Island do
  alias IslandsEngine.{Coordinate, Island}

  @enforce_keys [:coordinates, :hit_coordinates]
  defstruct [:coordinates, :hit_coordinates]

  def types() do
    [:atoll, :dot, :l_shape, :s_shape, :square]
  end

  #  Offsets to be used for the construction of the Island
  defp offsets(:square) do
    [{0, 0}, {0, 1}, {1, 0}, {1, 1}]
  end

  defp offsets(:atoll) do
    [{0, 0}, {0, 1}, {1, 1}, {2, 0}, {2, 1}]
  end

  defp offsets(:dot) do
    [{0, 0}]
  end

  defp offsets(:l_shape) do
    [{0, 0}, {1, 0}, {2, 0}, {2, 1}]
  end

  defp offsets(:s_shape) do
    [{0, 1}, {0, 2}, {1, 0}, {1, 1}]
  end

  defp offsets(_) do
    {:error, :invalid_island_type}
  end

  def new(type, %Coordinate{} = upper_left) do
    with [_h | _tail] = offsets      <- offsets(type), #offsets type exists and returns a list
         %MapSet{}    = coordinates  <- add_coordinates(offsets, upper_left) # add coordinates returns a MapSet
    do
      island = %Island{coordinates: coordinates, hit_coordinates: MapSet.new()}
      {:ok, island}
    else
      error -> error
    end
  end

  # Given a set of enumerable of offsets and the initial coordinate, this funciton will create
  # a set of Coordinate structs that represents the island
  defp add_coordinates(offsets, upper_left) do
    Enum.reduce_while(offsets, MapSet.new(), fn offset, acc ->
      add_coordinate(acc, upper_left, offset)
    end)
  end

  defp add_coordinate(coordinates, %Coordinate{row: row, col: col}, {row_offset, col_offset}) do
    case Coordinate.new(row + row_offset, col + col_offset) do
      {:ok, coordinate} ->
        {:cont, MapSet.put(coordinates, coordinate)}
      {:error, :invalid_coordinate} ->
        {:halt, {:error, :invalid_coordinate}}
    end
  end

  def overlaps?(%Island{} = existing_island, %Island{} = new_island) do
    not MapSet.disjoint?(existing_island.coordinates, new_island.coordinates)
  end

  def guess(%Island{} = island, %Coordinate{} = coordinate) do
    case MapSet.member?(island.coordinates, coordinate) do
      true ->
        island = %{island | hit_coordinates: MapSet.put(island.hit_coordinates, coordinate)}
        {:hit, island}
      false ->
        :miss
    end
  end

  def forested?(%Island{} = island) do
    MapSet.equal?(island.coordinates, island.hit_coordinates)
  end
end
