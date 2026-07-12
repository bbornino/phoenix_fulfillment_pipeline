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
        capacity: 42,
        city: "some city",
        manager_email: "some manager_email",
        manager_name: "some manager_name",
        name: "some name",
        state: "some state",
        zip: "some zip"
      })
      |> FulfillmentPipeline.Warehouses.create_warehouse()

    warehouse
  end
end
