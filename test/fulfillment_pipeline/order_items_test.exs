defmodule FulfillmentPipeline.OrderItemsTest do
  use FulfillmentPipeline.DataCase

  alias FulfillmentPipeline.OrderItems

  describe "order_items" do
    alias FulfillmentPipeline.OrderItems.OrderItem

    import FulfillmentPipeline.OrderItemsFixtures

    setup do
      warehouse = FulfillmentPipeline.WarehousesFixtures.warehouse_fixture()
      order = FulfillmentPipeline.FulfillmentFixtures.order_fixture(%{warehouse_id: warehouse.id})
      %{order: order}
    end

    @invalid_attrs %{
      status: nil,
      description: nil,
      sku: nil,
      quantity: nil,
      unit_price: nil,
      weight_lbs: nil,
      order_id: nil
    }

    test "list_order_items/0 returns all order_items" do
      order_item = order_item_fixture()
      assert OrderItems.list_order_items() == [order_item]
    end

    test "get_order_item!/1 returns the order_item with given id" do
      order_item = order_item_fixture()
      assert OrderItems.get_order_item!(order_item.id) == order_item
    end

    test "create_order_item/1 with valid data creates a order_item", %{order: order} do
      valid_attrs = %{
        order_id: order.id,
        status: "pending",
        description: "Wireless Headphones",
        sku: "SKU-001",
        quantity: 2,
        unit_price: "49.99",
        weight_lbs: "1.2"
      }

      assert {:ok, %OrderItem{} = order_item} = OrderItems.create_order_item(valid_attrs)
      assert order_item.status == "pending"
      assert order_item.description == "Wireless Headphones"
      assert order_item.sku == "SKU-001"
      assert order_item.quantity == 2
      assert order_item.unit_price == Decimal.new("49.99")
      assert order_item.weight_lbs == Decimal.new("1.2")
    end

    test "create_order_item/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = OrderItems.create_order_item(@invalid_attrs)
    end

    test "update_order_item/2 with valid data updates the order_item" do
      order_item = order_item_fixture()

      update_attrs = %{
        status: "picking",
        description: "Updated Headphones",
        sku: "SKU-001-B",
        quantity: 3,
        unit_price: "59.99",
        weight_lbs: "1.5"
      }

      assert {:ok, %OrderItem{} = order_item} =
               OrderItems.update_order_item(order_item, update_attrs)

      assert order_item.status == "picking"
      assert order_item.description == "Updated Headphones"
      assert order_item.sku == "SKU-001-B"
      assert order_item.quantity == 3
      assert order_item.unit_price == Decimal.new("59.99")
      assert order_item.weight_lbs == Decimal.new("1.5")
    end

    test "update_order_item/2 with invalid data returns error changeset" do
      order_item = order_item_fixture()

      assert {:error, %Ecto.Changeset{}} =
               OrderItems.update_order_item(order_item, @invalid_attrs)

      assert order_item == OrderItems.get_order_item!(order_item.id)
    end

    test "delete_order_item/1 deletes the order_item" do
      order_item = order_item_fixture()
      assert {:ok, %OrderItem{}} = OrderItems.delete_order_item(order_item)
      assert_raise Ecto.NoResultsError, fn -> OrderItems.get_order_item!(order_item.id) end
    end

    test "change_order_item/1 returns a order_item changeset" do
      order_item = order_item_fixture()
      assert %Ecto.Changeset{} = OrderItems.change_order_item(order_item)
    end
  end
end
