defmodule FulfillmentPipeline.WarehousesTest do
  use FulfillmentPipeline.DataCase

  alias FulfillmentPipeline.Warehouses

  describe "warehouses" do
    alias FulfillmentPipeline.Warehouses.Warehouse

    import FulfillmentPipeline.WarehousesFixtures

    @invalid_attrs %{active: nil, name: nil, state: nil, zip: nil, city: nil, capacity: nil, manager_name: nil, manager_email: nil}

    test "list_warehouses/0 returns all warehouses" do
      warehouse = warehouse_fixture()
      assert Warehouses.list_warehouses() == [warehouse]
    end

    test "get_warehouse!/1 returns the warehouse with given id" do
      warehouse = warehouse_fixture()
      assert Warehouses.get_warehouse!(warehouse.id) == warehouse
    end

    test "create_warehouse/1 with valid data creates a warehouse" do
      valid_attrs = %{active: true, name: "some name", state: "some state", zip: "some zip", city: "some city", capacity: 42, manager_name: "some manager_name", manager_email: "some manager_email"}

      assert {:ok, %Warehouse{} = warehouse} = Warehouses.create_warehouse(valid_attrs)
      assert warehouse.active == true
      assert warehouse.name == "some name"
      assert warehouse.state == "some state"
      assert warehouse.zip == "some zip"
      assert warehouse.city == "some city"
      assert warehouse.capacity == 42
      assert warehouse.manager_name == "some manager_name"
      assert warehouse.manager_email == "some manager_email"
    end

    test "create_warehouse/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Warehouses.create_warehouse(@invalid_attrs)
    end

    test "update_warehouse/2 with valid data updates the warehouse" do
      warehouse = warehouse_fixture()
      update_attrs = %{active: false, name: "some updated name", state: "some updated state", zip: "some updated zip", city: "some updated city", capacity: 43, manager_name: "some updated manager_name", manager_email: "some updated manager_email"}

      assert {:ok, %Warehouse{} = warehouse} = Warehouses.update_warehouse(warehouse, update_attrs)
      assert warehouse.active == false
      assert warehouse.name == "some updated name"
      assert warehouse.state == "some updated state"
      assert warehouse.zip == "some updated zip"
      assert warehouse.city == "some updated city"
      assert warehouse.capacity == 43
      assert warehouse.manager_name == "some updated manager_name"
      assert warehouse.manager_email == "some updated manager_email"
    end

    test "update_warehouse/2 with invalid data returns error changeset" do
      warehouse = warehouse_fixture()
      assert {:error, %Ecto.Changeset{}} = Warehouses.update_warehouse(warehouse, @invalid_attrs)
      assert warehouse == Warehouses.get_warehouse!(warehouse.id)
    end

    test "delete_warehouse/1 deletes the warehouse" do
      warehouse = warehouse_fixture()
      assert {:ok, %Warehouse{}} = Warehouses.delete_warehouse(warehouse)
      assert_raise Ecto.NoResultsError, fn -> Warehouses.get_warehouse!(warehouse.id) end
    end

    test "change_warehouse/1 returns a warehouse changeset" do
      warehouse = warehouse_fixture()
      assert %Ecto.Changeset{} = Warehouses.change_warehouse(warehouse)
    end
  end
end
