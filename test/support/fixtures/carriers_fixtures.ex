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
        code: "some code",
        max_weight_lbs: "120.5",
        name: "some name",
        tracking_url_template: "some tracking_url_template"
      })
      |> FulfillmentPipeline.Carriers.create_carrier()

    carrier
  end
end
