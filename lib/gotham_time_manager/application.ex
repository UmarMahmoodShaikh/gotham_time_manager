defmodule GothamTimeManager.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      GothamTimeManagerWeb.Telemetry,
      GothamTimeManager.Repo,
      {DNSCluster, query: Application.get_env(:gotham_time_manager, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: GothamTimeManager.PubSub},
      # Start a worker by calling: GothamTimeManager.Worker.start_link(arg)
      # {GothamTimeManager.Worker, arg},
      # Start to serve requests, typically the last entry
      GothamTimeManagerWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: GothamTimeManager.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    GothamTimeManagerWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
