defmodule Gravie.GiantBombClientTest do
  use ExUnit.Case
  alias Gravie.GiantBombClient

  describe "search games" do
    test "success: smoke test that searches for Star and get some results" do
      result = GiantBombClient.search_games("Star")
      IO.inspect(result, label: "Giant Bomb API results")
      assert Enum.count(result) > 0
      assert Enum.all?(result, &String.contains?(&1.name, "Star"))
    end
  end
end
