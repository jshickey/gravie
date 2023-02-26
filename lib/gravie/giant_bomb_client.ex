defmodule Gravie.GiantBombClient do
  use Tesla

  plug(Tesla.Middleware.BaseUrl, "https://www.giantbomb.com/api")
  plug Tesla.Middleware.Headers, [{"User-Agent", "Elixir"}]
  plug(Tesla.Middleware.JSON)

  @api_key Application.fetch_env!(:gravie, :giant_bomb_api_key)

  # TODO handle non-200 results
  # TODO write test if no access to Giant Bomb server
  def search_games(query) do
    {:ok, result} =
      get(
        "/games/?api_key=#{@api_key}" <>
          "&filter=name:#{query}" <> "&format=json&field_list=name,image,guid&limit=10"
      )

    result.body["results"]
    |> Enum.map(&%{name: &1["name"], guid: &1["guid"], thumb: &1["image"]["thumb_url"]})
  end

  # TODO when page > 0, page_size > 0
  def paginate(query, page \\ 1, page_size \\ 10) do
    {:ok, result} =
      get(
        "/games/?api_key=#{@api_key}" <>
          "&filter=name:#{query}" <>
          "&format=json&field_list=name,image,guid&limit=#{page_size}&offset=#{(page - 1) * page_size}"
      )

    games =
      result.body["results"]
      |> Enum.map(&%{name: &1["name"], guid: &1["guid"], thumb: &1["image"]["thumb_url"]})

    %{
      page: page,
      number_of_total_results: result.body["number_of_total_results"],
      page_size: page_size,
      games: games
    }
  end
end
