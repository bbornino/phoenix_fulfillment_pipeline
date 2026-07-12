defmodule FulfillmentPipeline.Application do
  # See https://elixir.hexdocs.pm/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      FulfillmentPipelineWeb.Telemetry,
      FulfillmentPipeline.Repo,
      {DNSCluster,
       query: Application.get_env(:fulfillment_pipeline, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: FulfillmentPipeline.PubSub},
      {Registry, keys: :unique, name: FulfillmentPipeline.Order.Registry},
      {DynamicSupervisor,
       name: FulfillmentPipeline.Order.DynamicSupervisor, strategy: :one_for_one},
      # Start a worker by calling: FulfillmentPipeline.Worker.start_link(arg)
      # {FulfillmentPipeline.Worker, arg},
      # Start to serve requests, typically the last entry
      FulfillmentPipelineWeb.Endpoint
    ]

    # See https://elixir.hexdocs.pm/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: FulfillmentPipeline.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    FulfillmentPipelineWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
