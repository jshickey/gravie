defmodule GravieWeb.SearchLive do
  alias Gravie.GiantBombClient
  use GravieWeb, :live_view

  def mount(_params, session, socket) do
    socket =
      assign(socket,
        query: "",
        results: [],
        loading: false,
        cart: MapSet.new()
      )

    socket =
      socket
      |> PhoenixLiveSession.maybe_subscribe(session)
      |> put_session_assigns(session)

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <nav
      class="relative flex w-full flex-nowrap items-center justify-between bg-neutral-100 py-4 text-neutral-500 shadow-lg hover:text-neutral-700 focus:text-neutral-700 lg:flex-wrap lg:justify-start"
      data-te-navbar-ref
    >
      <div class="flex w-full flex-wrap items-center justify-between px-6">
        <div
          class="!visible hidden flex-grow basis-[100%] items-center lg:!flex lg:basis-auto"
          id="navbarSupportedContent3"
          data-te-collapse-item
        >
          <a class="text-xl text-black" href="#">Gravie Games</a>
          <!-- Left links -->
          <ul class="list-style-none mr-auto flex flex-col pl-0 lg:flex-row" data-te-navbar-nav-ref>
            <li class="lg:pr-2" data-te-nav-item-ref>
              <.link
                class="p-0 text-neutral-1500 hover:text-neutral-700 focus:text-neutral-700 disabled:text-black/30 lg:px-2 [&.active]:text-black/90 dark:[&.active]:text-neutral-400"
                navigate={~p"/checkout"}
                data-te-nav-link-ref
              >
                Checkout
              </.link>
            </li>
            <li class="lg:px-2 text-neutral-400" data-te-nav-item-ref>
              >Search
            </li>
          </ul>
        </div>
        <!-- Collapsible wrapper -->
      </div>
    </nav>

    <div class="sm:flex sm:justify-center">Search for Games</div>
    <br />

    <div id="search">
      <form phx-submit="search">
        <div class="flex justify-center">
          <div class="mb-3 xl:w-96">
            <div class="relative mb-4 flex w-full flex-wrap items-stretch">
              <input
                type="search"
                name="query"
                value=""
                autofocus
                autocomplete="off"
                readonly={@loading}
                class="relative m-0 -mr-px block w-[1%] min-w-0 flex-auto rounded-l border border-solid border-neutral-300 bg-transparent bg-clip-padding px-3 py-1.5 text-base font-normal text-neutral-700 outline-none transition duration-300 ease-in-out focus:border-primary focus:text-neutral-700 focus:shadow-te-primary focus:outline-none dark:text-neutral-200 dark:placeholder:text-neutral-200"
                placeholder="Search"
                aria-label="Search"
                aria-describedby="button-addon1"
              />
              <button
                class="relative z-[2] flex items-center rounded-r bg-primary px-6 py-2.5 text-xs font-medium uppercase leading-tight text-white shadow-md transition duration-150 ease-in-out hover:bg-primary-700 hover:shadow-lg focus:bg-primary-700 focus:shadow-lg focus:outline-none focus:ring-0 active:bg-primary-800 active:shadow-lg"
                type="button"
                id="button-addon1"
                data-te-ripple-init
                data-te-ripple-color="light"
              >
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  viewBox="0 0 20 20"
                  fill="grey"
                  class="h-5 w-5"
                >
                  <path
                    fill-rule="evenodd"
                    d="M9 3.5a5.5 5.5 0 100 11 5.5 5.5 0 000-11zM2 9a7 7 0 1112.452 4.391l3.328 3.329a.75.75 0 11-1.06 1.06l-3.329-3.328A7 7 0 012 9z"
                    clip-rule="evenodd"
                  />
                </svg>
              </button>
              <div class="flex items-center justify-center">
                <div
                  :if={@loading}
                  class="inline-block h-8 w-8 animate-spin rounded-full border-4 border-solid border-current border-r-transparent align-[-0.125em] motion-reduce:animate-[spin_1.5s_linear_infinite]"
                  role="status"
                >
                  <span class="!absolute !-m-px !h-px !w-px !overflow-hidden !whitespace-nowrap !border-0 !p-0 ![clip:rect(0,0,0,0)]">
                    Loading...
                  </span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </form>

      <div class="grid gap-6 mb-8 md:grid-cols-2 xl:grid-cols-4">
        <%= for game <- @results do %>
          <div class="flex justify-center">
            <div class="flex flex-col rounded-lg bg-white shadow-lg dark:bg-neutral-700 md:max-w-xl md:flex-row">
              <img
                class=" rounded-t-m object-cover md:w-48 md:rounded-none md:rounded-l-lg"
                src={game.thumb}
                alt={game.name}
              />
              <div class="flex-1 md:w-48 flex-col justify-start p-6">
                <h5 class="mb-2 text-xl font-medium text-neutral-800 dark:text-neutral-50">
                  <%= game.name %>
                </h5>
                <button
                  phx-click="add_to_cart"
                  type="button"
                  value={game.guid}
                  class="inline-block rounded bg-primary px-6 pt-2.5 pb-2 text-xs font-medium uppercase leading-normal text-white shadow-[0_4px_9px_-4px_#3b71ca] transition duration-150 ease-in-out hover:bg-primary-600 hover:shadow-[0_8px_9px_-4px_rgba(59,113,202,0.3),0_4px_18px_0_rgba(59,113,202,0.2)] focus:bg-primary-600 focus:shadow-[0_8px_9px_-4px_rgba(59,113,202,0.3),0_4px_18px_0_rgba(59,113,202,0.2)] focus:outline-none focus:ring-0 active:bg-primary-700 active:shadow-[0_8px_9px_-4px_rgba(59,113,202,0.3),0_4px_18px_0_rgba(59,113,202,0.2)]"
                  data-te-ripple-init
                  data-te-ripple-color="light"
                >
                  Add to Cart
                </button>
              </div>
            </div>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  def handle_event("add_to_cart", %{"value" => guid}, socket) do
    game = Enum.find(socket.assigns.results, &(&1.guid == guid))

    updated_cart = MapSet.put(socket.assigns.cart, game)
    PhoenixLiveSession.put_session(socket, "cart", updated_cart)

    socket =
      assign(socket,
        cart: updated_cart
      )

    IO.inspect(socket.assigns.cart, label: "cart")
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

  def handle_info({:live_session_updated, session}, socket) do
    {:noreply, put_session_assigns(socket, session)}
  end

  def handle_info({:fetch_games, query}, socket) do
    socket =
      assign(socket,
        results: GiantBombClient.search_games(query),
        loading: false
      )

    {:noreply, socket}
  end

  defp put_session_assigns(socket, session) do
    socket
    |> assign(:cart, Map.get(session, "cart", MapSet.new()))
  end
end
