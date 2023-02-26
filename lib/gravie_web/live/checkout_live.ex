defmodule GravieWeb.CheckoutLive do
  use GravieWeb, :live_view

  def mount(_params, session, socket) do
    IO.inspect(session, label: "CHECKOUT:MOUNT:SESSION")

    socket =
      assign(socket,
        cart: Map.get(session, "cart")
      )

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
            <li class="lg:px-2 text-neutral-1000" data-te-nav-item-ref>
              >Checkout
            </li>
            <li class="lg:pr-2" data-te-nav-item-ref>
              <.link
                class="p-0 text-neutral-500 hover:text-neutral-700 focus:text-neutral-700 disabled:text-black/30 lg:px-2 [&.active]:text-black/90 dark:[&.active]:text-neutral-400"
                navigate={~p"/search"}
                data-te-nav-link-ref
              >
                Search
              </.link>
            </li>
          </ul>
        </div>
        <!-- Collapsible wrapper -->
      </div>
    </nav>
    <div>
      <div class="grid gap-6 mb-8 md:grid-cols-2 xl:grid-cols-4">
        <%= for game <- @cart do %>
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
                  phx-click="remove_from_cart"
                  type="button"
                  value={game.guid}
                  class="inline-block rounded bg-primary px-6 pt-2.5 pb-2 text-xs font-medium uppercase leading-normal text-white shadow-[0_4px_9px_-4px_#3b71ca] transition duration-150 ease-in-out hover:bg-primary-600 hover:shadow-[0_8px_9px_-4px_rgba(59,113,202,0.3),0_4px_18px_0_rgba(59,113,202,0.2)] focus:bg-primary-600 focus:shadow-[0_8px_9px_-4px_rgba(59,113,202,0.3),0_4px_18px_0_rgba(59,113,202,0.2)] focus:outline-none focus:ring-0 active:bg-primary-700 active:shadow-[0_8px_9px_-4px_rgba(59,113,202,0.3),0_4px_18px_0_rgba(59,113,202,0.2)]"
                  data-te-ripple-init
                  data-te-ripple-color="light"
                >
                  Remove From Cart
                </button>
              </div>
            </div>
          </div>
        <% end %>
      </div>
    </div>
    """
  end
end
