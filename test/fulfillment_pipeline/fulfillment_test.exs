defmodule FulfillmentPipeline.FulfillmentTest do
  use FulfillmentPipeline.DataCase

  alias FulfillmentPipeline.Fulfillment

  describe "orders" do
    alias FulfillmentPipeline.Fulfillment.Order

    import FulfillmentPipeline.FulfillmentFixtures

    setup do
      warehouse = FulfillmentPipeline.WarehousesFixtures.warehouse_fixture()
      %{warehouse: warehouse}
    end

    @invalid_attrs %{
      priority: nil,
      status: nil,
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
      page = Fulfillment.list_orders()
      assert page.total_entries == 1
      assert hd(page.entries).id == order.id
    end

    test "get_order!/1 returns the order with given id" do
      order = order_fixture()
      assert Fulfillment.get_order!(order.id) == order
    end

    test "create_order/1 with valid data creates a order", %{warehouse: warehouse} do
      valid_attrs = %{
        priority: "standard",
        status: "received",
        order_number: "ORD-TEST-001",
        customer_name: "Jane Smith",
        customer_email: "jane@example.com",
        notes: "Test notes",
        requires_signature: true,
        estimated_ship_date: ~D[2026-07-15],
        warehouse_id: warehouse.id
      }

      assert {:ok, %Order{} = order} = Fulfillment.create_order(valid_attrs)
      assert order.priority == "standard"
      assert order.status == "received"
      assert order.order_number == "ORD-TEST-001"
      assert order.customer_name == "Jane Smith"
      assert order.customer_email == "jane@example.com"
      assert order.notes == "Test notes"
      assert order.requires_signature == true
      assert order.estimated_ship_date == ~D[2026-07-15]
      assert order.warehouse_id == warehouse.id
    end

    test "create_order/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Fulfillment.create_order(@invalid_attrs)
    end

    test "update_order/2 with valid data updates the order", %{warehouse: warehouse} do
      order = order_fixture()

      update_attrs = %{
        priority: "expedited",
        status: "picking",
        order_number: "ORD-TEST-001-UPDATED",
        customer_name: "Jane Smith Updated",
        customer_email: "jane.updated@example.com",
        notes: "Updated notes",
        requires_signature: false,
        estimated_ship_date: ~D[2026-07-20],
        warehouse_id: warehouse.id
      }

      assert {:ok, %Order{} = order} = Fulfillment.update_order(order, update_attrs)
      assert order.priority == "expedited"
      assert order.status == "picking"

      assert order.order_number == "ORD-TEST-001-UPDATED"
      assert order.customer_name == "Jane Smith Updated"
      assert order.customer_email == "jane.updated@example.com"
      assert order.notes == "Updated notes"
      assert order.requires_signature == false
      assert order.estimated_ship_date == ~D[2026-07-20]
      assert order.warehouse_id == warehouse.id
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

  describe "order validations" do
    setup do
      warehouse = FulfillmentPipeline.WarehousesFixtures.warehouse_fixture()
      %{warehouse: warehouse}
    end

    test "rejects invalid email format", %{warehouse: warehouse} do
      attrs = %{
        priority: "standard",
        status: "received",
        order_number: "ORD-VAL-001",
        customer_name: "Jane Smith",
        customer_email: "not-an-email",
        estimated_ship_date: ~D[2026-07-15],
        warehouse_id: warehouse.id
      }

      assert {:error, changeset} = Fulfillment.create_order(attrs)
      assert %{customer_email: ["has invalid format"]} = errors_on(changeset)
    end

    test "rejects invalid status", %{warehouse: warehouse} do
      attrs = %{
        priority: "standard",
        status: "flying",
        order_number: "ORD-VAL-002",
        customer_name: "Jane Smith",
        customer_email: "jane@example.com",
        estimated_ship_date: ~D[2026-07-15],
        warehouse_id: warehouse.id
      }

      assert {:error, changeset} = Fulfillment.create_order(attrs)
      assert %{status: ["is invalid"]} = errors_on(changeset)
    end

    test "rejects invalid priority", %{warehouse: warehouse} do
      attrs = %{
        priority: "super-duper-rush",
        status: "received",
        order_number: "ORD-VAL-003",
        customer_name: "Jane Smith",
        customer_email: "jane@example.com",
        estimated_ship_date: ~D[2026-07-15],
        warehouse_id: warehouse.id
      }

      assert {:error, changeset} = Fulfillment.create_order(attrs)
      assert %{priority: ["is invalid"]} = errors_on(changeset)
    end

    test "accepts all valid statuses", %{warehouse: warehouse} do
      ~w(received picking packing shipping delivered exception)
      |> Enum.each(fn status ->
        attrs = %{
          priority: "standard",
          status: status,
          order_number: "ORD-#{status}",
          customer_name: "Jane Smith",
          customer_email: "jane@example.com",
          estimated_ship_date: ~D[2026-07-15],
          warehouse_id: warehouse.id
        }

        assert {:ok, _order} = Fulfillment.create_order(attrs)
      end)
    end

    test "accepts all valid priorities", %{warehouse: warehouse} do
      ~w(standard expedited overnight)
      |> Enum.with_index()
      |> Enum.each(fn {priority, index} ->
        attrs = %{
          priority: priority,
          status: "received",
          order_number: "ORD-PRI-#{index}",
          customer_name: "Jane Smith",
          customer_email: "jane@example.com",
          estimated_ship_date: ~D[2026-07-15],
          warehouse_id: warehouse.id
        }

        assert {:ok, _order} = Fulfillment.create_order(attrs)
      end)
    end

    test "enforces unique order numbers", %{warehouse: warehouse} do
      attrs = %{
        priority: "standard",
        status: "received",
        order_number: "ORD-DUPE-001",
        customer_name: "Jane Smith",
        customer_email: "jane@example.com",
        estimated_ship_date: ~D[2026-07-15],
        warehouse_id: warehouse.id
      }

      assert {:ok, _order} = Fulfillment.create_order(attrs)

      duplicate_attrs = Map.put(attrs, :customer_name, "Different Name")
      assert {:error, changeset} = Fulfillment.create_order(duplicate_attrs)
      assert %{order_number: ["has already been taken"]} = errors_on(changeset)
    end
  end
end
