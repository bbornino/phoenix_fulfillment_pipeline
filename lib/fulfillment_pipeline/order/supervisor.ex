defmodule FulfillmentPipeline.Order.Supervisor do
  alias FulfillmentPipeline.Order.Server

  def start_order(order_id) do
    DynamicSupervisor.start_child(
      __MODULE__,
      {Server, order_id}
    )
  end

  def stop_order(order_id) do
    case Registry.lookup(FulfillmentPipeline.Order.Registry, order_id) do
      [{pid, _}] -> DynamicSupervisor.terminate_child(__MODULE__, pid)
      [] -> {:error, :not_found}
    end
  end
end
