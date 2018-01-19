defmodule IslandsEngine.GuessesTest do
  use ExUnit.Case
  alias IslandsEngine.{Guesses, Coordinate}

  test "new/1 returns an empty set for hits and misses" do
    %Guesses{hits: h, misses: m} = Guesses.new

    assert MapSet.size(h) == 0
    assert MapSet.size(m) == 0
  end

  test "add/3 when adding misses" do
    guesses = Guesses.new
    {:ok, coordinate} = Coordinate.new(1, 1)
    %Guesses{hits: h, misses: m} = Guesses.add(guesses, :miss, coordinate)

    assert m == MapSet.new [coordinate]
    assert 0 == MapSet.size(h)
  end

  test "add/3 when adding hits" do
    guesses = Guesses.new
    {:ok, coordinate} = Coordinate.new(1, 1)
    %Guesses{hits: h, misses: m} = Guesses.add(guesses, :hit, coordinate)

    assert h == MapSet.new [coordinate]
    assert 0 == MapSet.size(m)
  end
end