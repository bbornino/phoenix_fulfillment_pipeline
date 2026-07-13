defmodule FulfillmentPipeline.Order.Hydrator do
  alias FulfillmentPipeline.Fulfillment
  alias FulfillmentPipeline.Order.Supervisor, as: OrderSupervisor

  def start_all do
    if Application.get_env(:fulfillment_pipeline, :env) != :test do
      Fulfillment.list_orders()
      |> Enum.reject(&(&1.status == "delivered"))
      |> Enum.each(fn order ->
        OrderSupervisor.start_order(order.id)
      end)
    end
  end
end
