defmodule IslandsEngine.BoardTest do
  use ExUnit.Case
  alias IslandsEngine.Board

  test "new/1 returns an empty map" do
    assert %{} == Board.new 
  end
end