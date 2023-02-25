defmodule GravieWeb.SearchLive do
  alias Gravie.GiantBombClient
  use GravieWeb, :live_view

  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        query: "",
        results: [],
        loading: false
      )

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <h1>Search for Games</h1>
    <div>
      <form phx-submit="search">
        <input
          type="text"
          name="query"
          value=""
          placeholder="Name of a game"
          autofocus
          autocomplete="off"
          readonly={@loading}
        />
      </form>
      <div
        :if={@loading}
        class="ml-auto inline-block h-8 w-8 animate-spin rounded-full border-4 border-solid border-current border-r-transparent align-[-0.125em] motion-reduce:animate-[spin_1.5s_linear_infinite]"
        role="status"
      >
        Loading...
      </div>
      <div>
        <ul>
          <li :for={game <- @results}>
            <span>
              <img src={game.thumb} />
            </span>
            <span>
              <%= game.name %>
            </span>
          </li>
        </ul>
      </div>
    </div>
    """
  end

  def handle_info({:fetch_games, query}, socket) do
    socket =
      assign(socket,
        results: GiantBombClient.search_games(query),
        loading: false
      )

    {:noreply, socket}
  end

  def handle_event("search", %{"query" => query}, socket) do
    send(self(), {:fetch_games, query})

    socket =
      assign(socket,
        query: query,
        results: [],
        loading: true
      )

    {:noreply, socket}
  end
end
