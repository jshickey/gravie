defmodule Gravie.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      GravieWeb.Telemetry,
      # Start the Ecto repository
      Gravie.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Gravie.PubSub},
      # Start Finch
      {Finch, name: Gravie.Finch},
      # Start the Endpoint (http/https)
      GravieWeb.Endpoint
      # Start a worker by calling: Gravie.Worker.start_link(arg)
      # {Gravie.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Gravie.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    GravieWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
