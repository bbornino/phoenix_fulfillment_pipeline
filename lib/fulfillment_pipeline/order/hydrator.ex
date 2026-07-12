defmodule FulfillmentPipeline.Order.Hydrator do
  alias FulfillmentPipeline.Fulfillment
  alias FulfillmentPipeline.Order.Supervisor, as: OrderSupervisor

  def start_all do
    Fulfillment.list_orders()
    |> Enum.reject(&(&1.status == "delivered"))
    |> Enum.each(fn order ->
      OrderSupervisor.start_order(order.id)
    end)
  end
end
