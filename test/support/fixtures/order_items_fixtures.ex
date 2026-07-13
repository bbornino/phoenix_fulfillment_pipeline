defmodule FulfillmentPipeline.OrderItemsFixtures do
  alias FulfillmentPipeline.FulfillmentFixtures
  alias FulfillmentPipeline.WarehousesFixtures

  def order_item_fixture(attrs \\ %{}) do
    warehouse = WarehousesFixtures.warehouse_fixture()
    order = FulfillmentFixtures.order_fixture(%{warehouse_id: warehouse.id})

    {:ok, order_item} =
      attrs
      |> Enum.into(%{
        order_id: order.id,
        sku: "SKU-001",
        description: "Wireless Headphones",
        quantity: 2,
        unit_price: "49.99",
        weight_lbs: "1.2",
        status: "pending"
      })
      |> FulfillmentPipeline.OrderItems.create_order_item()

    order_item
  end
end
