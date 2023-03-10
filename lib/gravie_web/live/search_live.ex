defmodule GravieWeb.SearchLive do
  alias Gravie.GiantBombClient
  use GravieWeb, :live_view

  def mount(_params, session, socket) do
    # The shopping cart is going to managed in global cache keyed by the session id.
    # Multiple LiveView screens can share the same the session. The session isn't
    # available in every LiveView function, but the cache can be called directly.
    session_id = Map.get(session, :__sid__)

    # Use the cart out of the cache if it exists, or create a new one.
    {:ok, session_cart} = Cachex.get(:gravie_cache, session_id)

    cart =
      if session_cart && session_id do
        session_cart
      else
        MapSet.new()
      end

    # Initalize the Search screen state.
    socket =
      assign(socket,
        query: "",
        games: [],
        loading: false,
        cart: cart,
        page: 1,
        number_of_total_results: 0,
        session_id: session_id
      )

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <.nav>
      <%= MapSet.size(@cart) %>
    </.nav>

    <div class="sm:flex sm:justify-center">Search for Games</div>
    <div class="sm:flex sm:justify-center"><%= "Results Found: #{@number_of_total_results}" %></div>

    <br />

    <div id="search">
      <form phx-submit="search">
        <div class="flex justify-center">
          <div class="mb-3 xl:w-96">
            <div class="relative mb-4 flex w-full flex-wrap items-stretch">
              <.search_input query={@query} loading={@loading} />
              <.search_button />
              <.spinner loading={@loading} />
            </div>
          </div>
        </div>
      </form>

      <div :if={Enum.count(@games) > 0} class="grid gap-6 mb-8 md:grid-cols-2 xl:grid-cols-4">
        <div class="flex justify-center space-x-6">
          <.pagination_button click_event="prev-page">Prev</.pagination_button>
          <.pagination_button click_event="next-page">Next</.pagination_button>
        </div>
        <%= for game <- @games do %>
          <.game_card thumb={game.thumb} name={game.name} guid={game.guid}>Add To Cart</.game_card>
        <% end %>
      </div>
    </div>
    """
  end

  def handle_params(params, _uri, socket) do
    IO.inspect(params, label: "SEARCH:HANDLE_PARAMS")

    # Read the page number from the params URL. Default to page 1
    # if there is nothing in the page and query.
    page =
      if params["page"] && socket.assigns.query != "" do
        String.to_integer(params["page"])
      else
        1
      end

    # Publish a message to fetch a new page of data only if the query is filled
    # and the page has changed. Set the loading spinner to true
    # if fetching new data.
    loading =
      if socket.assigns.query != "" && page != socket.assigns.page do
        send(self(), {:fetch_games, socket.assigns.query, page})
        true
      else
        false
      end

    # Update the state of our Search page with the page number passed in on the params.
    socket =
      assign(socket,
        page: page,
        loading: loading
      )

    {:noreply, socket}
  end

  # Update the shopping cart with the game selected and push to the cache
  def handle_event("add_to_cart", %{"value" => guid}, socket) do
    game_selected = Enum.find(socket.assigns.games, &(&1.guid == guid))
    updated_cart = MapSet.put(socket.assigns.cart, game_selected)
    Cachex.put(:gravie_cache, socket.assigns.session_id, updated_cart)

    socket =
      assign(socket,
        cart: updated_cart
      )

    {:noreply, socket}
  end

  # Handle the clicking on the search button by publishing a message
  # to fetch new data and start the spinner.
  def handle_event("search", %{"query" => query}, socket) do
    send(self(), {:fetch_games, query, 1})

    socket =
      assign(socket,
        query: query,
        games: [],
        loading: true,
        page: 1
      )
    {:noreply, push_patch(socket, to: ~p"/search")}

    #{:noreply, socket}
  end

  # Calculate the previous page and patch the LiveView session,
  # versus doing a redirect so that the page isn't
  # re-mounted.
  def handle_event("prev-page", _, socket) do
    current_page = socket.assigns.page

    page =
      if current_page > 1 do
        current_page - 1
      else
        current_page
      end

    {:noreply, push_patch(socket, to: ~p"/search?page=#{page}")}
  end

  def handle_event("next-page", _, socket) do
    current_page = socket.assigns.page
    total = socket.assigns.number_of_total_results

    page =
      if current_page <= total / 10 do
        current_page + 1
      else
        current_page
      end

    {:noreply, push_patch(socket, to: ~p"/search?page=#{page}")}
  end

  # Listen for a message to fetch games and call the API client.
  # Update the session with a list of games and turn off the spinner.
  def handle_info({:fetch_games, query, page}, socket) do
    api_resp = GiantBombClient.paginate(query, page)

    socket =
      assign(socket,
        games: api_resp.games,
        number_of_total_results: api_resp.number_of_total_results,
        loading: false
      )

    {:noreply, socket}
  end

  # FUNCTION COMPONENTS
  def search_input(assigns) do
    ~H"""
    <input
      type="search"
      name="query"
      value={@query}
      autofocus
      autocomplete="off"
      readonly={@loading}
      class="relative m-0 -mr-px block w-[1%] min-w-0 flex-auto rounded-l border border-solid border-neutral-300 bg-transparent bg-clip-padding px-3 py-1.5 text-base font-normal text-neutral-700 outline-none transition duration-300 ease-in-out focus:border-primary focus:text-neutral-700 focus:shadow-te-primary focus:outline-none dark:text-neutral-200 dark:placeholder:text-neutral-200"
      placeholder="Search"
      aria-label="Search"
      aria-describedby="button-addon1"
    />
    """
  end

  def game_card(assigns) do
    ~H"""
    <div class="flex justify-center">
      <div class="flex flex-col rounded-lg bg-white shadow-lg dark:bg-neutral-700 md:max-w-xl md:flex-row">
        <img
          class=" rounded-t-m object-cover md:w-48 md:rounded-none md:rounded-l-lg"
          src={@thumb}
          alt={@name}
        />
        <div class="flex-1 md:w-48 flex-col justify-start p-6">
          <h5 class="mb-2 text-xl font-medium text-neutral-800 dark:text-neutral-50">
            <%= @name %>
          </h5>
          <button
            phx-click="add_to_cart"
            type="button"
            value={@guid}
            class="inline-block rounded bg-neutral-500 px-6 pt-2.5 pb-2 text-xs font-medium uppercase leading-normal text-white shadow-[0_4px_9px_-4px_#3b71ca] transition duration-150 ease-in-out hover:bg-primary-600 hover:shadow-[0_8px_9px_-4px_rgba(59,113,202,0.3),0_4px_18px_0_rgba(59,113,202,0.2)] focus:bg-primary-600 focus:shadow-[0_8px_9px_-4px_rgba(59,113,202,0.3),0_4px_18px_0_rgba(59,113,202,0.2)] focus:outline-none focus:ring-0 active:bg-primary-700 active:shadow-[0_8px_9px_-4px_rgba(59,113,202,0.3),0_4px_18px_0_rgba(59,113,202,0.2)]"
            data-te-ripple-init
            data-te-ripple-color="light"
          >
            <%= render_slot(@inner_block) %>
          </button>
        </div>
      </div>
    </div>
    """
  end

  def pagination_button(assigns) do
    ~H"""
    <button
      phx-click={@click_event}
      class="h-2/6	bg-gray-300 hover:bg-gray-400 text-gray-800 font-bold py-2 px-4 rounded-l"
    >
      <%= render_slot(@inner_block) %>
    </button>
    """
  end

  def spinner(assigns) do
    ~H"""
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
    """
  end

  def search_button(assigns) do
    ~H"""
    <button
      phx-submit="search"
      class="relative z-[2] flex items-center rounded-r bg-neutral-800 px-6 py-2.5 text-xs font-medium uppercase leading-tight text-white shadow-md transition duration-150 ease-in-out hover:bg-primary-700 hover:shadow-lg focus:bg-primary-700 focus:shadow-lg focus:outline-none focus:ring-0 active:bg-primary-800 active:shadow-lg"
      type="submit"
      id="button-addon1"
      data-te-ripple-init
      data-te-ripple-color="light"
    >
      <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="grey" class="h-5 w-5">
        <path
          fill-rule="evenodd"
          d="M9 3.5a5.5 5.5 0 100 11 5.5 5.5 0 000-11zM2 9a7 7 0 1112.452 4.391l3.328 3.329a.75.75 0 11-1.06 1.06l-3.329-3.328A7 7 0 012 9z"
          clip-rule="evenodd"
        />
      </svg>
    </button>
    """
  end

  def nav(assigns) do
    ~H"""
    <nav
      class="relative flex w-full flex-wrap items-center justify-between bg-neutral-900 py-3 text-neutral-200 shadow-lg lg:flex-wrap lg:justify-start"
      data-te-navbar-ref
    >
      <div class="flex w-full flex-wrap items-center justify-between px-6">
        <button
          class="block border-0 bg-transparent py-2 px-2.5 text-neutral-200 hover:no-underline hover:shadow-none focus:no-underline focus:shadow-none focus:outline-none focus:ring-0 lg:hidden"
          type="button"
          data-te-collapse-init
          data-te-target="#navbarSupportedContent4"
          aria-controls="navbarSupportedContent4"
          aria-expanded="false"
          aria-label="Toggle navigation"
        >
          <span class="[&>svg]:w-7">
            <svg
              xmlns="http://www.w3.org/2000/svg"
              viewBox="0 0 24 24"
              fill="currentColor"
              class="h-7 w-7"
            >
              <path
                fill-rule="evenodd"
                d="M3 6.75A.75.75 0 013.75 6h16.5a.75.75 0 010 1.5H3.75A.75.75 0 013 6.75zM3 12a.75.75 0 01.75-.75h16.5a.75.75 0 010 1.5H3.75A.75.75 0 013 12zm0 5.25a.75.75 0 01.75-.75h16.5a.75.75 0 010 1.5H3.75a.75.75 0 01-.75-.75z"
                clip-rule="evenodd"
              />
            </svg>
          </span>
        </button>
        <div
          class="!visible hidden flex-grow basis-[100%] items-center lg:!flex lg:basis-auto"
          id="navbarSupportedContent4"
          data-te-collapse-item
        >
          <a class="pr-2 text-xl font-semibold text-white" href="#">Gravie Games</a>
          <!-- Left links -->
          <ul class="list-style-none mr-auto flex flex-col pl-0 lg:flex-row" data-te-navbar-nav-ref>
            <li class="p-2" data-te-nav-item-ref>
              <a
                class="p-0 text-white opacity-60 hover:opacity-80 focus:opacity-80 disabled:text-black/30 lg:px-2 [&.active]:text-black/90 dark:[&.active]:text-neutral-400"
                data-te-nav-link-ref
              >
                Search
              </a>
            </li>
            <li class="p-2" data-te-nav-item-ref>
              <.link
                class="text-white disabled:text-black/30 lg:px-2 [&.active]:text-black/90 dark:[&.active]:text-neutral-400"
                data-te-nav-link-ref
                navigate={~p"/checkout"}
              >
                Checkout
              </.link>
            </li>
          </ul>
          <!-- Left links -->
        </div>
        <!-- Collapsible wrapper -->

    <!-- Right elements -->
        <div class="relative flex items-center">
          <!-- Icon -->
          <a class="mr-4 text-white opacity-60 hover:opacity-80 focus:opacity-80" href="#">
            <span class="[&>svg]:w-5">
              <svg
                xmlns="http://www.w3.org/2000/svg"
                viewBox="0 0 24 24"
                fill="currentColor"
                class="h-5 w-5"
              >
                <path d="M2.25 2.25a.75.75 0 000 1.5h1.386c.17 0 .318.114.362.278l2.558 9.592a3.752 3.752 0 00-2.806 3.63c0 .414.336.75.75.75h15.75a.75.75 0 000-1.5H5.378A2.25 2.25 0 017.5 15h11.218a.75.75 0 00.674-.421 60.358 60.358 0 002.96-7.228.75.75 0 00-.525-.965A60.864 60.864 0 005.68 4.509l-.232-.867A1.875 1.875 0 003.636 2.25H2.25zM3.75 20.25a1.5 1.5 0 113 0 1.5 1.5 0 01-3 0zM16.5 20.25a1.5 1.5 0 113 0 1.5 1.5 0 01-3 0z" />
              </svg>
              <%= render_slot(@inner_block) %>
            </span>
          </a>
        </div>
        <!-- Right elements -->
      </div>
    </nav>
    """
  end
end
