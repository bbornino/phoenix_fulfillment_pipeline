defmodule FulfillmentPipeline.FulfillmentFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `FulfillmentPipeline.Fulfillment` context.
  """

  @doc """
  Generate a order.
  """
  def order_fixture(attrs \\ %{}) do
    {:ok, order} =
      attrs
      |> Enum.into(%{
        customer_email: "some customer_email",
        customer_name: "some customer_name",
        estimated_ship_date: ~D[2026-07-11],
        items: %{},
        notes: "some notes",
        order_number: "some order_number",
        priority: "some priority",
        requires_signature: true,
        status: "some status",
        warehouse_id: 42
      })
      |> FulfillmentPipeline.Fulfillment.create_order()

    order
  end
end
