defmodule FulfillmentPipeline.CarriersTest do
  use FulfillmentPipeline.DataCase

  alias FulfillmentPipeline.Carriers

  describe "carriers" do
    alias FulfillmentPipeline.Carriers.Carrier

    import FulfillmentPipeline.CarriersFixtures

    @invalid_attrs %{
      active: nil,
      code: nil,
      name: nil,
      max_weight_lbs: nil,
      tracking_url_template: nil
    }

    test "list_carriers/0 returns all carriers" do
      carrier = carrier_fixture()
      assert Carriers.list_carriers() == [carrier]
    end

    test "get_carrier!/1 returns the carrier with given id" do
      carrier = carrier_fixture()
      assert Carriers.get_carrier!(carrier.id) == carrier
    end

    test "create_carrier/1 with valid data creates a carrier" do
      valid_attrs = %{
        active: true,
        code: "fedex",
        name: "FedEx Ground",
        max_weight_lbs: "150.0",
        tracking_url_template: "https://www.fedex.com/apps/fedextrack/?tracknumbers="
      }

      assert {:ok, %Carrier{} = carrier} = Carriers.create_carrier(valid_attrs)
      assert carrier.active == true
      assert carrier.code == "fedex"
      assert carrier.name == "FedEx Ground"
      assert carrier.max_weight_lbs == Decimal.new("150.0")

      assert carrier.tracking_url_template ==
               "https://www.fedex.com/apps/fedextrack/?tracknumbers="
    end

    test "create_carrier/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Carriers.create_carrier(@invalid_attrs)
    end

    test "update_carrier/2 with valid data updates the carrier" do
      carrier = carrier_fixture()

      update_attrs = %{
        active: false,
        code: "fedex-ltl",
        name: "FedEx LTL Freight",
        max_weight_lbs: "2000.0",
        tracking_url_template: "https://www.fedex.com/apps/fedextrack/?tracknumbers="
      }

      assert {:ok, %Carrier{} = carrier} = Carriers.update_carrier(carrier, update_attrs)
      assert carrier.active == false
      assert carrier.code == "fedex-ltl"
      assert carrier.name == "FedEx LTL Freight"
      assert carrier.max_weight_lbs == Decimal.new("2000.0")

      assert carrier.tracking_url_template ==
               "https://www.fedex.com/apps/fedextrack/?tracknumbers="
    end

    test "update_carrier/2 with invalid data returns error changeset" do
      carrier = carrier_fixture()
      assert {:error, %Ecto.Changeset{}} = Carriers.update_carrier(carrier, @invalid_attrs)
      assert carrier == Carriers.get_carrier!(carrier.id)
    end

    test "delete_carrier/1 deletes the carrier" do
      carrier = carrier_fixture()
      assert {:ok, %Carrier{}} = Carriers.delete_carrier(carrier)
      assert_raise Ecto.NoResultsError, fn -> Carriers.get_carrier!(carrier.id) end
    end

    test "change_carrier/1 returns a carrier changeset" do
      carrier = carrier_fixture()
      assert %Ecto.Changeset{} = Carriers.change_carrier(carrier)
    end
  end
end
