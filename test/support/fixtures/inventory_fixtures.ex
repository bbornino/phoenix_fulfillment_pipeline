defmodule FulfillmentPipeline.InventoryFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `FulfillmentPipeline.Inventory` context.
  """

  @doc """
  Generate a inventory_item.
  """
  def inventory_item_fixture(attrs \\ %{}) do
    {:ok, inventory_item} =
      attrs
      |> Enum.into(%{
        description: "some description",
        quantity_on_hand: 42,
        quantity_reserved: 42,
        reorder_point: 42,
        sku: "some sku",
        unit_cost: "120.5"
      })
      |> FulfillmentPipeline.Inventory.create_inventory_item()

    inventory_item
  end
end
