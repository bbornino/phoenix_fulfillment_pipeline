defmodule FulfillmentPipeline.Order.Server do
  use GenServer

  alias FulfillmentPipeline.Fulfillment

  # ---- Client API ----

  def start_link(order_id) do
    GenServer.start_link(__MODULE__, order_id, name: via(order_id))
  end

  def get_state(order_id) do
    GenServer.call(via(order_id), :get_state)
  end

  def advance(order_id) do
    GenServer.cast(via(order_id), :advance)
  end

  def trigger_exception(order_id) do
    GenServer.cast(via(order_id), :trigger_exception)
  end

  # ---- Server Callbacks ----

  @impl true
  def init(order_id) do
    order = Fulfillment.get_order!(order_id)
    {:ok, order}
  end

  @impl true
  def handle_call(:get_state, _from, order) do
    {:reply, order, order}
  end

  @impl true
  def handle_cast(:advance, order) do
    new_status = next_status(order.status)
    {:ok, updated_order} = Fulfillment.update_order(order, %{status: new_status})

    Phoenix.PubSub.broadcast(
      FulfillmentPipeline.PubSub,
      "orders",
      {:order_updated, updated_order}
    )

    {:noreply, updated_order}
  end

  @impl true
  def handle_cast(:trigger_exception, order) do
    {:ok, updated_order} = Fulfillment.update_order(order, %{status: "exception"})

    Phoenix.PubSub.broadcast(
      FulfillmentPipeline.PubSub,
      "orders",
      {:order_updated, updated_order}
    )

    {:noreply, updated_order}
  end

  # ---- Private ----
  defp next_status("received"), do: "picking"
  defp next_status("picking"), do: "packing"
  defp next_status("packing"), do: "shipping"
  defp next_status("shipping"), do: "delivered"
  defp next_status(status), do: status

  defp via(order_id) do
    {:via, Registry, {FulfillmentPipeline.Order.Registry, order_id}}
  end
end
