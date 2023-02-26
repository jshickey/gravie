# Gravie

To start your Phoenix server:

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix

## Project Notes
* Build-in Dababase migrations
* use of built-in pub sub for sending UI event messages to server side functions
* cachex for sharing shopping cart based on session_id
* JSON -> map vs -> struct decision
* testability of functions inside of LiveView
* hiding secrets
* Architectual Signficance of Solution
** Sockets gives SPA performance with server side coding
** only one language to learn
** Build-in Dababase migrations
** function crashing doesn't destroy server or even parent processes
* Files to Look At
*** search_live.exe
*** checkout_live.exe
*** giant_bomb_client.ex
