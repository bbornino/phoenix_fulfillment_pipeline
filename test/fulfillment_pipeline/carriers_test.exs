defmodule FulfillmentPipeline.CarriersTest do
  use FulfillmentPipeline.DataCase

  alias FulfillmentPipeline.Carriers

  describe "carriers" do
    alias FulfillmentPipeline.Carriers.Carrier

    import FulfillmentPipeline.CarriersFixtures

    @invalid_attrs %{active: nil, code: nil, name: nil, max_weight_lbs: nil, tracking_url_template: nil}

    test "list_carriers/0 returns all carriers" do
      carrier = carrier_fixture()
      assert Carriers.list_carriers() == [carrier]
    end

    test "get_carrier!/1 returns the carrier with given id" do
      carrier = carrier_fixture()
      assert Carriers.get_carrier!(carrier.id) == carrier
    end

    test "create_carrier/1 with valid data creates a carrier" do
      valid_attrs = %{active: true, code: "some code", name: "some name", max_weight_lbs: "120.5", tracking_url_template: "some tracking_url_template"}

      assert {:ok, %Carrier{} = carrier} = Carriers.create_carrier(valid_attrs)
      assert carrier.active == true
      assert carrier.code == "some code"
      assert carrier.name == "some name"
      assert carrier.max_weight_lbs == Decimal.new("120.5")
      assert carrier.tracking_url_template == "some tracking_url_template"
    end

    test "create_carrier/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Carriers.create_carrier(@invalid_attrs)
    end

    test "update_carrier/2 with valid data updates the carrier" do
      carrier = carrier_fixture()
      update_attrs = %{active: false, code: "some updated code", name: "some updated name", max_weight_lbs: "456.7", tracking_url_template: "some updated tracking_url_template"}

      assert {:ok, %Carrier{} = carrier} = Carriers.update_carrier(carrier, update_attrs)
      assert carrier.active == false
      assert carrier.code == "some updated code"
      assert carrier.name == "some updated name"
      assert carrier.max_weight_lbs == Decimal.new("456.7")
      assert carrier.tracking_url_template == "some updated tracking_url_template"
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
