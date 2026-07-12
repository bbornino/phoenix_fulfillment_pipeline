defmodule FulfillmentPipeline.WarehousesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `FulfillmentPipeline.Warehouses` context.
  """

  @doc """
  Generate a warehouse.
  """
  def warehouse_fixture(attrs \\ %{}) do
    {:ok, warehouse} =
      attrs
      |> Enum.into(%{
        active: true,
        capacity: 500,
        city: "Sacramento",
        manager_email: "joe@fulfillmentpipeline.com",
        manager_name: "Joe Smith",
        name: "Sacramento Fulfillment Center",
        state: "CA",
        zip: "95814"
      })
      |> FulfillmentPipeline.Warehouses.create_warehouse()

    warehouse
  end
end
