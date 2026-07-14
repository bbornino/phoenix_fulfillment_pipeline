defmodule FulfillmentPipeline.InventoryFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `FulfillmentPipeline.Inventory` context.
  """

  def inventory_item_fixture(attrs \\ %{}) do
    warehouse = FulfillmentPipeline.WarehousesFixtures.warehouse_fixture()

    {:ok, inventory_item} =
      attrs
      |> Enum.into(%{
        warehouse_id: warehouse.id,
        sku: "SKU-#{System.unique_integer([:positive])}",
        description: "Wireless Headphones",
        quantity_on_hand: 100,
        quantity_reserved: 10,
        reorder_point: 20,
        unit_cost: "49.99"
      })
      |> FulfillmentPipeline.Inventory.create_inventory_item()

    inventory_item
  end
end
