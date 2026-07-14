defmodule FulfillmentPipeline.InventoryTest do
  use FulfillmentPipeline.DataCase

  alias FulfillmentPipeline.Inventory

  describe "inventory_items" do
    alias FulfillmentPipeline.Inventory.InventoryItem

    import FulfillmentPipeline.InventoryFixtures

    setup do
      warehouse = FulfillmentPipeline.WarehousesFixtures.warehouse_fixture()
      %{warehouse: warehouse}
    end

    @invalid_attrs %{
      description: nil,
      sku: nil,
      quantity_on_hand: nil,
      reorder_point: nil,
      unit_cost: nil,
      warehouse_id: nil
    }

    test "list_inventory_items/0 returns all inventory_items" do
      inventory_item = inventory_item_fixture()
      assert Inventory.list_inventory_items() == [inventory_item]
    end

    test "get_inventory_item!/1 returns the inventory_item with given id" do
      inventory_item = inventory_item_fixture()
      assert Inventory.get_inventory_item!(inventory_item.id) == inventory_item
    end

    test "create_inventory_item/1 with valid data creates a inventory_item", %{
      warehouse: warehouse
    } do
      valid_attrs = %{
        warehouse_id: warehouse.id,
        sku: "SKU-001",
        description: "Wireless Headphones",
        quantity_on_hand: 100,
        quantity_reserved: 10,
        reorder_point: 20,
        unit_cost: "49.99"
      }

      assert {:ok, %InventoryItem{} = inventory_item} =
               Inventory.create_inventory_item(valid_attrs)

      assert inventory_item.sku == "SKU-001"
      assert inventory_item.description == "Wireless Headphones"
      assert inventory_item.quantity_on_hand == 100
      assert inventory_item.quantity_reserved == 10
      assert inventory_item.reorder_point == 20
      assert inventory_item.unit_cost == Decimal.new("49.99")
    end

    test "create_inventory_item/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Inventory.create_inventory_item(@invalid_attrs)
    end

    test "update_inventory_item/2 with valid data updates the inventory_item" do
      inventory_item = inventory_item_fixture()

      update_attrs = %{
        description: "Updated Headphones",
        quantity_on_hand: 75,
        quantity_reserved: 5,
        reorder_point: 15,
        unit_cost: "59.99"
      }

      assert {:ok, %InventoryItem{} = inventory_item} =
               Inventory.update_inventory_item(inventory_item, update_attrs)

      assert inventory_item.description == "Updated Headphones"
      assert inventory_item.quantity_on_hand == 75
      assert inventory_item.quantity_reserved == 5
      assert inventory_item.reorder_point == 15
      assert inventory_item.unit_cost == Decimal.new("59.99")
    end

    test "update_inventory_item/2 with invalid data returns error changeset" do
      inventory_item = inventory_item_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Inventory.update_inventory_item(inventory_item, @invalid_attrs)

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

    test "low_stock_items/0 returns items at or below reorder point" do
      warehouse = FulfillmentPipeline.WarehousesFixtures.warehouse_fixture()

      {:ok, low_item} =
        Inventory.create_inventory_item(%{
          warehouse_id: warehouse.id,
          sku: "SKU-LOW",
          description: "Low Stock Item",
          quantity_on_hand: 5,
          quantity_reserved: 0,
          reorder_point: 10,
          unit_cost: "9.99"
        })

      {:ok, _ok_item} =
        Inventory.create_inventory_item(%{
          warehouse_id: warehouse.id,
          sku: "SKU-OK",
          description: "Well Stocked Item",
          quantity_on_hand: 100,
          quantity_reserved: 0,
          reorder_point: 10,
          unit_cost: "9.99"
        })

      low_items = Inventory.low_stock_items()
      assert Enum.any?(low_items, fn i -> i.id == low_item.id end)
      refute Enum.any?(low_items, fn i -> i.sku == "SKU-OK" end)
    end

    test "list_inventory_items_for_warehouse/1 returns only items for that warehouse" do
      warehouse = FulfillmentPipeline.WarehousesFixtures.warehouse_fixture()
      other_warehouse = FulfillmentPipeline.WarehousesFixtures.warehouse_fixture()

      {:ok, item} =
        Inventory.create_inventory_item(%{
          warehouse_id: warehouse.id,
          sku: "SKU-W1",
          description: "Warehouse 1 Item",
          quantity_on_hand: 50,
          quantity_reserved: 0,
          reorder_point: 10,
          unit_cost: "19.99"
        })

      {:ok, _other_item} =
        Inventory.create_inventory_item(%{
          warehouse_id: other_warehouse.id,
          sku: "SKU-W2",
          description: "Warehouse 2 Item",
          quantity_on_hand: 50,
          quantity_reserved: 0,
          reorder_point: 10,
          unit_cost: "19.99"
        })

      items = Inventory.list_inventory_items_for_warehouse(warehouse.id)
      assert length(items) == 1
      assert hd(items).id == item.id
    end
  end
end
