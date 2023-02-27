defmodule GravieWeb.CheckoutLive do
  use GravieWeb, :live_view
  alias Gravie.Rentals

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

    socket =
      assign(socket,
        session_id: session_id,
        cart: cart
      )

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <.nav><%= MapSet.size(@cart) %></.nav>
    <h2>SHOPPING CART:</h2>
    <div>
      <form phx-submit="cart-checkout">
        <label for="email">Email:</label>
        <input type="text" id="email" name="email" />
        <button type="Submit">Rent Now</button>
      </form>
    </div>
    <div>
      <div :if={MapSet.size(@cart) == 0}>Shopping Cart is Empty</div>
      <div :if={@cart} class="grid gap-6 mb-8 md:grid-cols-2 xl:grid-cols-4">
        <%= for game <- @cart do %>
          <.game_card
            thumb={game.thumb}
            name={game.name}
            guid={game.guid}
            event_name="remove_from_cart"
          >
            Remove From Cart
          </.game_card>
        <% end %>
      </div>
    </div>
    """
  end

  def handle_event("remove_from_cart", %{"value" => guid}, socket) do
    game = Enum.find(socket.assigns.cart, &(&1.guid == guid))
    updated_cart = MapSet.delete(socket.assigns.cart, game)

    IO.inspect(updated_cart, label: "CHECKOUT:remove_from_cart:updated_cart")

    Cachex.put(:gravie_cache, socket.assigns.session_id, updated_cart)
    IO.puts("done with updating Cachex.cache")

    socket =
      assign(socket,
        cart: updated_cart
      )

    IO.inspect(socket.assigns.cart, label: "cart")
    {:noreply, socket}
  end

  # Function Components
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
            phx-click={@event_name}
            type="button"
            value={@guid}
            class="inline-block rounded bg-primary px-6 pt-2.5 pb-2 text-xs font-medium uppercase leading-normal text-white shadow-[0_4px_9px_-4px_#3b71ca] transition duration-150 ease-in-out hover:bg-primary-600 hover:shadow-[0_8px_9px_-4px_rgba(59,113,202,0.3),0_4px_18px_0_rgba(59,113,202,0.2)] focus:bg-primary-600 focus:shadow-[0_8px_9px_-4px_rgba(59,113,202,0.3),0_4px_18px_0_rgba(59,113,202,0.2)] focus:outline-none focus:ring-0 active:bg-primary-700 active:shadow-[0_8px_9px_-4px_rgba(59,113,202,0.3),0_4px_18px_0_rgba(59,113,202,0.2)]"
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

  def handle_event("cart-checkout", %{"email" => email}, socket) do
    socket.assigns.cart
    |> Enum.map(&Rentals.create_rental(%{email: email, game_guid: &1.guid}))
    socket = socket
    |> put_flash(:info, "Rating submitted successfully")
    {:noreply, socket}
  end

  def handle_event("remove_from_cart", %{"value" => guid}, socket) do
    game = Enum.find(socket.assigns.cart, &(&1.guid == guid))
    updated_cart = MapSet.delete(socket.assigns.cart, game)

    IO.inspect(updated_cart, label: "CHECKOUT:remove_from_cart:updated_cart")

    Cachex.put(:gravie_cache, socket.assigns.session_id, updated_cart)
    IO.puts("done with updating Cachex.cache")

    socket =
      assign(socket,
        cart: updated_cart
      )

    IO.inspect(socket.assigns.cart, label: "cart")
    {:noreply, socket}
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
              <.link
                class="text-white disabled:text-black/30 lg:px-2 [&.active]:text-black/90 dark:[&.active]:text-neutral-400"
                navigate={~p"/search"}
                data-te-nav-link-ref
              >
                Search
              </.link>
            </li>
            <li class="p-2" data-te-nav-item-ref>
              <a
                class="p-0 text-white opacity-60 hover:opacity-80 focus:opacity-80 disabled:text-black/30 lg:px-2 [&.active]:text-black/90 dark:[&.active]:text-neutral-400"
                data-te-nav-link-ref
              >
                Checkout
              </a>
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
