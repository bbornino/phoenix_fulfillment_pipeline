defmodule FulfillmentPipelineWeb.OperationsLive do
  use FulfillmentPipelineWeb, :live_view

  alias FulfillmentPipeline.Carriers
  alias FulfillmentPipeline.Inventory
  alias FulfillmentPipeline.Warehouses

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       carriers: Carriers.list_carriers(),
       low_stock_items: Inventory.low_stock_items(),
       warehouses: Warehouses.list_warehouses(),
       selected_warehouse_id: nil,
       warehouse_inventory: []
     )}
  end

  @impl true
  def handle_event("select_warehouse", %{"id" => id}, socket) do
    warehouse_id = String.to_integer(id)
    inventory = Inventory.list_inventory_items_for_warehouse(warehouse_id)

    {:noreply,
     assign(socket,
       selected_warehouse_id: warehouse_id,
       warehouse_inventory: inventory
     )}
  end
end
