defmodule IslandsEngine.IslandTest do
  use ExUnit.Case
  alias IslandsEngine.{Island, Coordinate}

  test "new/2 yields :invalid_island_type for unkown types" do
    {:ok, coordinate} = Coordinate.new(4, 6)
    {:error, :invalid_island_type} = Island.new(:wrong, coordinate)
  end

  test "new/2 yields :invalid_island_type for unkown types and invalid coordinate" do
    {:error, :invalid_island_type} = Island.new(:wrong, %Coordinate{row: 12, col: 6})
  end

  test "new/2 yields :invalid_coordinate for kown types but invalid coordinate" do
    {:error, :invalid_coordinate} = Island.new(:atoll, %Coordinate{row: 12, col: 6})
  end

  test "new/2 populates coordinates" do
    {:ok, coordinate} = Coordinate.new(4, 6)
    {:ok, %Island{coordinates: coordinates, hit_coordinates: hit_coordinates}} = Island.new(:l_shape, coordinate)

    assert MapSet.size(coordinates) == 4
    assert MapSet.size(hit_coordinates) == 0
  end

  test "overlaps?/2" do
    dot = dot_island()
    square = square_island()
    l_shape = l_shape_island()

    assert Island.overlaps?(square, dot) == true
    assert Island.overlaps?(square, l_shape) == false
    assert Island.overlaps?(dot, l_shape) == false
  end

  test "guess/2 when guess is a miss, it returns :miss" do
    dot = dot_island()
    {:ok, coordinate} = Coordinate.new(2, 2)

    assert Island.guess(dot, coordinate) == :miss
  end

  test "guess/2 when guess is a hit, it adds the hit to the island hits MapSet" do
    dot = dot_island()
    [coordinate|_t] = MapSet.to_list(dot.coordinates) # use a coordinate fromthe island, to ensure the hit

    {:hit, island} = Island.guess(dot, coordinate)
    assert MapSet.member?(island.hit_coordinates, coordinate)
  end

  test "forested/1" do 
    dot = dot_island()
    assert not Island.forested?(dot)

    [coordinate|_t] = MapSet.to_list(dot.coordinates) # use a coordinate fromthe island, to ensure the hit
    {:hit, island} = Island.guess(dot, coordinate)
    # dot island has been hit in the only coordinate
    assert Island.forested?(island)
  end

  defp dot_island() do
    {:ok, dot_coordinate} = Coordinate.new(1, 2)
    {:ok, dot} = Island.new(:dot, dot_coordinate)

    dot    
  end

  defp square_island() do
    {:ok, square_coordinate} = Coordinate.new(1, 1)
    {:ok, square} = Island.new(:square, square_coordinate)

    square
  end

  defp l_shape_island() do
    {:ok, l_shape_coordinate} = Coordinate.new(5, 5)
    {:ok, l_shape} = Island.new(:l_shape, l_shape_coordinate)

    l_shape
  end
end