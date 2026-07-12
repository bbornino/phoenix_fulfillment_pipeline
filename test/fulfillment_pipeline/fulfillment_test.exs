defmodule FulfillmentPipeline.FulfillmentTest do
  use FulfillmentPipeline.DataCase

  alias FulfillmentPipeline.Fulfillment

  describe "orders" do
    alias FulfillmentPipeline.Fulfillment.Order

    import FulfillmentPipeline.FulfillmentFixtures

    @invalid_attrs %{
      priority: nil,
      status: nil,
      items: nil,
      order_number: nil,
      customer_name: nil,
      customer_email: nil,
      notes: nil,
      requires_signature: nil,
      estimated_ship_date: nil,
      warehouse_id: nil
    }

    test "list_orders/0 returns all orders" do
      order = order_fixture()
      assert Fulfillment.list_orders() == [order]
    end

    test "get_order!/1 returns the order with given id" do
      order = order_fixture()
      assert Fulfillment.get_order!(order.id) == order
    end

    test "create_order/1 with valid data creates a order" do
      valid_attrs = %{
        priority: "standard",
        status: "received",
        items: %{},
        order_number: "ORD-TEST-001",
        customer_name: "Jane Smith",
        customer_email: "jane@example.com",
        notes: "Test notes",
        requires_signature: true,
        estimated_ship_date: ~D[2026-07-15],
        warehouse_id: 1
      }

      assert {:ok, %Order{} = order} = Fulfillment.create_order(valid_attrs)
      assert order.priority == "standard"
      assert order.status == "received"
      assert order.items == %{}
      assert order.order_number == "ORD-TEST-001"
      assert order.customer_name == "Jane Smith"
      assert order.customer_email == "jane@example.com"
      assert order.notes == "Test notes"
      assert order.requires_signature == true
      assert order.estimated_ship_date == ~D[2026-07-15]
      assert order.warehouse_id == 1
    end

    test "create_order/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Fulfillment.create_order(@invalid_attrs)
    end

    test "update_order/2 with valid data updates the order" do
      order = order_fixture()

      update_attrs = %{
        priority: "expedited",
        status: "picking",
        items: %{},
        order_number: "ORD-TEST-001-UPDATED",
        customer_name: "Jane Smith Updated",
        customer_email: "jane.updated@example.com",
        notes: "Updated notes",
        requires_signature: false,
        estimated_ship_date: ~D[2026-07-20],
        warehouse_id: 2
      }

      assert {:ok, %Order{} = order} = Fulfillment.update_order(order, update_attrs)
      assert order.priority == "expedited"
      assert order.status == "picking"
      assert order.items == %{}
      assert order.order_number == "ORD-TEST-001-UPDATED"
      assert order.customer_name == "Jane Smith Updated"
      assert order.customer_email == "jane.updated@example.com"
      assert order.notes == "Updated notes"
      assert order.requires_signature == false
      assert order.estimated_ship_date == ~D[2026-07-20]
      assert order.warehouse_id == 2
    end

    test "update_order/2 with invalid data returns error changeset" do
      order = order_fixture()
      assert {:error, %Ecto.Changeset{}} = Fulfillment.update_order(order, @invalid_attrs)
      assert order == Fulfillment.get_order!(order.id)
    end

    test "delete_order/1 deletes the order" do
      order = order_fixture()
      assert {:ok, %Order{}} = Fulfillment.delete_order(order)
      assert_raise Ecto.NoResultsError, fn -> Fulfillment.get_order!(order.id) end
    end

    test "change_order/1 returns a order changeset" do
      order = order_fixture()
      assert %Ecto.Changeset{} = Fulfillment.change_order(order)
    end
  end
end
