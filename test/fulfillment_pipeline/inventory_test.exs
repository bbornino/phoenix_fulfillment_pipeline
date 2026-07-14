defmodule FulfillmentPipeline.InventoryTest do
  use FulfillmentPipeline.DataCase

  alias FulfillmentPipeline.Inventory

  describe "inventory_items" do
    alias FulfillmentPipeline.Inventory.InventoryItem

    import FulfillmentPipeline.InventoryFixtures

    @invalid_attrs %{description: nil, sku: nil, quantity_on_hand: nil, quantity_reserved: nil, reorder_point: nil, unit_cost: nil}

    test "list_inventory_items/0 returns all inventory_items" do
      inventory_item = inventory_item_fixture()
      assert Inventory.list_inventory_items() == [inventory_item]
    end

    test "get_inventory_item!/1 returns the inventory_item with given id" do
      inventory_item = inventory_item_fixture()
      assert Inventory.get_inventory_item!(inventory_item.id) == inventory_item
    end

    test "create_inventory_item/1 with valid data creates a inventory_item" do
      valid_attrs = %{description: "some description", sku: "some sku", quantity_on_hand: 42, quantity_reserved: 42, reorder_point: 42, unit_cost: "120.5"}

      assert {:ok, %InventoryItem{} = inventory_item} = Inventory.create_inventory_item(valid_attrs)
      assert inventory_item.description == "some description"
      assert inventory_item.sku == "some sku"
      assert inventory_item.quantity_on_hand == 42
      assert inventory_item.quantity_reserved == 42
      assert inventory_item.reorder_point == 42
      assert inventory_item.unit_cost == Decimal.new("120.5")
    end

    test "create_inventory_item/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Inventory.create_inventory_item(@invalid_attrs)
    end

    test "update_inventory_item/2 with valid data updates the inventory_item" do
      inventory_item = inventory_item_fixture()
      update_attrs = %{description: "some updated description", sku: "some updated sku", quantity_on_hand: 43, quantity_reserved: 43, reorder_point: 43, unit_cost: "456.7"}

      assert {:ok, %InventoryItem{} = inventory_item} = Inventory.update_inventory_item(inventory_item, update_attrs)
      assert inventory_item.description == "some updated description"
      assert inventory_item.sku == "some updated sku"
      assert inventory_item.quantity_on_hand == 43
      assert inventory_item.quantity_reserved == 43
      assert inventory_item.reorder_point == 43
      assert inventory_item.unit_cost == Decimal.new("456.7")
    end

    test "update_inventory_item/2 with invalid data returns error changeset" do
      inventory_item = inventory_item_fixture()
      assert {:error, %Ecto.Changeset{}} = Inventory.update_inventory_item(inventory_item, @invalid_attrs)
      assert inventory_item == Inventory.get_inventory_item!(inventory_item.id)
    end

    test "delete_inventory_item/1 deletes the inventory_item" do
      inventory_item = inventory_item_fixture()
      assert {:ok, %InventoryItem{}} = Inventory.delete_inventory_item(inventory_item)
      assert_raise Ecto.NoResultsError, fn -> Inventory.get_inventory_item!(inventory_item.id) end
    end

    test "change_inventory_item/1 returns a inventory_item changeset" do
      inventory_item = inventory_item_fixture()
      assert %Ecto.Changeset{} = Inventory.change_inventory_item(inventory_item)
    end
  end
end
