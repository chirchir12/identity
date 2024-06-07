defmodule Identity.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      IdentityWeb.Telemetry,
      Identity.Repo,
      {DNSCluster, query: Application.get_env(:identity, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Identity.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Identity.Finch},
      # Start a worker by calling: Identity.Worker.start_link(arg)
      # {Identity.Worker, arg},
      # Start to serve requests, typically the last entry
      IdentityWeb.Endpoint,
      {Guardian.DB.Token.SweeperServer, []}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Identity.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    IdentityWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
