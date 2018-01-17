defmodule IslandsEngine.CoordinateTest do
  use ExUnit.Case
  alias IslandsEngine.Coordinate

  test "new/2 returns error when row or col are out of board_range" do
    # assuming board range is 1..10
    assert Coordinate.new(0, 1) == {:error, :invalid_coordinate}
    assert Coordinate.new(11, 1) == {:error, :invalid_coordinate}

    assert Coordinate.new(1, 0) == {:error, :invalid_coordinate}
    assert Coordinate.new(1, 11) == {:error, :invalid_coordinate}
  end

    test "new/2 returns ok and coordinate when row or col are within board_range" do
    # assuming board range is 1..10
    assert Coordinate.new(1, 1) == {:ok, %Coordinate{row: 1, col: 1}}
    assert Coordinate.new(10, 1) == {:ok, %Coordinate{row: 10, col: 1}}

    assert Coordinate.new(2, 3) == {:ok, %Coordinate{row: 2, col: 3}}
    assert Coordinate.new(4, 5) == {:ok, %Coordinate{row: 4, col: 5}}    
  end

  test "new/2 returns a tuple like {:ok, %Coordinate{} = coordinate} when values are good" do
    assert {:ok, %Coordinate{} = _coordinate} = Coordinate.new(4, 5)
  end

end
