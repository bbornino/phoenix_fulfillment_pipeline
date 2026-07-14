defmodule FulfillmentPipeline.Order.Hydrator do
  @doc """
  Restores active order processes on application boot.

  Queries all non-delivered orders from the database and starts
  a GenServer process for each one, ensuring in-memory state
  matches persistent state after a restart.
  """

  alias FulfillmentPipeline.Fulfillment
  alias FulfillmentPipeline.Order.Supervisor, as: OrderSupervisor

  def start_all do
    if Application.get_env(:fulfillment_pipeline, :env) != :test do
      Fulfillment.list_active_orders()
      |> Enum.each(fn order ->
        OrderSupervisor.start_order(order.id)
      end)
    end
  end
end
