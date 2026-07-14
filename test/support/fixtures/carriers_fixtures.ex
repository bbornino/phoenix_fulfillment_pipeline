defmodule FulfillmentPipeline.CarriersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `FulfillmentPipeline.Carriers` context.
  """

  @doc """
  Generate a carrier.
  """
  def carrier_fixture(attrs \\ %{}) do
    {:ok, carrier} =
      attrs
      |> Enum.into(%{
        active: true,
        code: "ups-#{System.unique_integer([:positive])}",
        max_weight_lbs: "150.0",
        name: "UPS Ground",
        tracking_url_template: "https://www.ups.com/track?tracknum="
      })
      |> FulfillmentPipeline.Carriers.create_carrier()

    carrier
  end
end
