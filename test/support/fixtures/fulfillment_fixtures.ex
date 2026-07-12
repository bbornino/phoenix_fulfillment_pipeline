defmodule FulfillmentPipeline.FulfillmentFixtures do
  def order_fixture(attrs \\ %{}) do
    warehouse = FulfillmentPipeline.WarehousesFixtures.warehouse_fixture()

    {:ok, order} =
      attrs
      |> Enum.into(%{
        customer_email: "test@example.com",
        customer_name: "Test Customer",
        estimated_ship_date: ~D[2026-07-15],
        items: %{},
        notes: "Test order notes",
        order_number: "ORD-#{System.unique_integer([:positive])}",
        priority: "standard",
        requires_signature: false,
        status: "received",
        warehouse_id: warehouse.id
      })
      |> FulfillmentPipeline.Fulfillment.create_order()

    FulfillmentPipeline.Repo.preload(order, :warehouse)
  end
end
