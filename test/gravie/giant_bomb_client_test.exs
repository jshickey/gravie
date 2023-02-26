defmodule Gravie.GiantBombClientTest do
  use ExUnit.Case
  alias Gravie.GiantBombClient

  describe "search games" do
    test "success: smoke test that searches for Star and get some results" do
      result = GiantBombClient.search_games("Star")
      IO.inspect(result, label: "Giant Bomb API results")
      assert Enum.count(result) > 0
      assert Enum.all?(result, &String.contains?(String.downcase(&1.name), "star"))
    end

    test "success: test getting first page of paginated query with default params" do
      result = GiantBombClient.paginate("Star")
      IO.inspect(result, label: "Giant Bomb API results")

      assert result.number_of_total_results > 0

      assert Enum.count(result.games) > 0
      assert Enum.all?(result.games, &String.contains?(String.downcase(&1.name), "star"))
    end

    test "success: test getting second page of paginated query" do
      result = GiantBombClient.paginate("Star", 2, 10)
      IO.inspect(result, label: "Giant Bomb API results")
      assert result.number_of_total_results > 0
      assert Enum.count(result.games) > 0
      assert Enum.all?(result.games, &String.contains?(String.downcase(&1.name), "star"))
    end
  end
end
