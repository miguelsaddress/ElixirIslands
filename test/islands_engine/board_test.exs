defmodule IslandsEngine.BoardTest do
  use ExUnit.Case
  alias IslandsEngine.{Board, Coordinate, Island}

  test "new/1 returns an empty map" do
    assert %{} == Board.new
  end

  test "position_island/3 positions island when board is empty and cordinate is right" do
    {:ok, square_coordinate} = Coordinate.new(1, 1)
    {:ok, square} = Island.new(:square, square_coordinate)

    board =
      Board.new()
      |> Board.position_island(:square, square)

    assert board.square == square
  end

  test "position_island/3 returns {:error, :overlapping_island} when island overlaps existing one" do
    {:ok, square_coordinate} = Coordinate.new(1, 1)
    {:ok, square} = Island.new(:square, square_coordinate)

    {:ok, dot_coordinate} = Coordinate.new(2, 2)
    {:ok, dot} = Island.new(:dot, dot_coordinate)

    {:error, :overlapping_island} =
      Board.new()
      |> Board.position_island(:square, square)
      |> Board.position_island(:dot, dot)
  end

  test "all_islands_positioned?/1 is false when no island positioned" do
    board = Board.new
    assert Board.all_islands_positioned?(board) == false
  end

  test "all_islands_positioned?/1 is false when only one island is positioned" do
    {:ok, dot_coordinate} = Coordinate.new(2, 2)
    {:ok, dot} = Island.new(:dot, dot_coordinate)

    board =
      Board.new()
      |> Board.position_island(:dot, dot)

    assert not Board.all_islands_positioned?(board)
  end

  test "all_islands_positioned?/1 is false when not all islands are positioned" do
    # a couple of islands should be enough...

    {:ok, square_coordinate} = Coordinate.new(1, 1)
    {:ok, square} = Island.new(:square, square_coordinate)

    {:ok, dot_coordinate} = Coordinate.new(4, 5)
    {:ok, dot} = Island.new(:dot, dot_coordinate)

    board =
      Board.new()
      |> Board.position_island(:square, square)
      |> Board.position_island(:dot, dot)

    assert not Board.all_islands_positioned?(board)
  end

  test "all_islands_positioned?/1 is true when all islands are positioned" do
    # [x][x][ ][ ][ ][ ][ ][ ][ ][ ]
    # [x][x][ ][x][ ][ ][ ][ ][x][x]
    # [ ][ ][ ][ ][ ][ ][ ][ ][ ][x]
    # [ ][ ][ ][x][ ][ ][ ][ ][x][x]
    # [ ][ ][ ][x][ ][ ][ ][ ][ ][ ]
    # [ ][ ][ ][x][x][ ][ ][ ][ ][ ]
    # [ ][ ][ ][ ][ ][ ][ ][ ][ ][ ]
    # [ ][ ][ ][ ][ ][x][x][ ][ ][ ]
    # [ ][ ][ ][ ][x][x][ ][ ][ ][ ]
    # [ ][ ][ ][ ][ ][ ][ ][ ][ ][ ]

    {:ok, square_coordinate} = Coordinate.new(1, 1)
    {:ok, square} = Island.new(:square, square_coordinate)

    {:ok, dot_coordinate} = Coordinate.new(2, 4)
    {:ok, dot} = Island.new(:dot, dot_coordinate)

    {:ok, atoll_coordinate} = Coordinate.new(2, 9)
    {:ok, atoll} = Island.new(:atoll, atoll_coordinate)

    {:ok, l_shape_coordinate} = Coordinate.new(4, 4)
    {:ok, l_shape} = Island.new(:l_shape, l_shape_coordinate)

    {:ok, s_shape_coordinate} = Coordinate.new(7, 6)
    {:ok, s_shape} = Island.new(:s_shape, s_shape_coordinate)

    board =
      Board.new()
      |> Board.position_island(:square, square)
      |> Board.position_island(:dot, dot)
      |> Board.position_island(:atoll, atoll)
      |> Board.position_island(:l_shape, l_shape)
      |> Board.position_island(:s_shape, s_shape)

    assert Board.all_islands_positioned?(board)
  end

  test "guess/2 is a hit and win" do
    {:ok, dot_coordinate} = Coordinate.new(2, 2)
    {:ok, dot} = Island.new(:dot, dot_coordinate)

    {:hit, :dot, :win, _board} =
      Board.new()
      |> Board.position_island(:dot, dot)
      |> Board.guess(dot_coordinate)
  end

  test "guess/2 is a hit but no win" do
    {:ok, dot_coordinate} = Coordinate.new(2, 2)
    {:ok, dot} = Island.new(:dot, dot_coordinate)

    {:ok, atoll_coordinate} = Coordinate.new(2, 9)
    {:ok, atoll} = Island.new(:atoll, atoll_coordinate)

    {:hit, :dot, :no_win, _board} =
      Board.new()
      |> Board.position_island(:dot, dot)
      |> Board.position_island(:atoll, atoll)
      |> Board.guess(dot_coordinate)
  end

  test "guess/2 is a miss and no_win" do
    {:ok, dot_coordinate} = Coordinate.new(2, 2)
    {:ok, dot} = Island.new(:dot, dot_coordinate)

    {:ok, atoll_coordinate} = Coordinate.new(2, 9)
    {:ok, atoll} = Island.new(:atoll, atoll_coordinate)

    {:ok, miss_coordinate} = Coordinate.new(6,6)
    {:miss, :none, :no_win, _board} =
      Board.new()
      |> Board.position_island(:dot, dot)
      |> Board.position_island(:atoll, atoll)
      |> Board.guess(miss_coordinate)
  end
end
