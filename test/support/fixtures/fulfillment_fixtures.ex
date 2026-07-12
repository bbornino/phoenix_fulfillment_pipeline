defmodule FulfillmentPipeline.FulfillmentFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `FulfillmentPipeline.Fulfillment` context.
  """

  def order_fixture(attrs \\ %{}) do
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
        warehouse_id: 1
      })
      |> FulfillmentPipeline.Fulfillment.create_order()

    order
  end
end
