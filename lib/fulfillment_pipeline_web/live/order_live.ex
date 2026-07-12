defmodule FulfillmentPipelineWeb.OrderLive do
  use FulfillmentPipelineWeb, :live_view

  alias FulfillmentPipeline.Fulfillment
  alias FulfillmentPipeline.Order.Supervisor, as: OrderSupervisor
  alias FulfillmentPipeline.Order.Server

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(FulfillmentPipeline.PubSub, "orders")
    end

    orders = Fulfillment.list_orders()
    {:ok, assign(socket, orders: orders)}
  end

  @impl true
  def handle_info({:order_updated, updated_order}, socket) do
    orders =
      Enum.map(socket.assigns.orders, fn order ->
        if order.id == updated_order.id, do: updated_order, else: order
      end)

    {:noreply, assign(socket, orders: orders)}
  end

  @impl true
  def handle_event("advance", %{"id" => id}, socket) do
    Server.advance(String.to_integer(id))
    {:noreply, socket}
  end

  @impl true
  def handle_event("trigger_exception", %{"id" => id}, socket) do
    Server.trigger_exception(String.to_integer(id))
    {:noreply, socket}
  end

  defp status_color("received"), do: "#888"
  defp status_color("picking"), do: "#f59e0b"
  defp status_color("packing"), do: "#f59e0b"
  defp status_color("shipping"), do: "#3b82f6"
  defp status_color("delivered"), do: "#22c55e"
  defp status_color("exception"), do: "#ef4444"
  defp status_color(_), do: "#888"
end
