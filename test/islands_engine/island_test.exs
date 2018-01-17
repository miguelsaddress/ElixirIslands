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

end