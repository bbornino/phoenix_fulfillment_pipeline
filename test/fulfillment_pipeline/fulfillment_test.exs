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

    test "list_orders/1 with no sort returns orders by id" do
      first = order_fixture()
      second = order_fixture()
      assert ids(Fulfillment.list_orders(%{})) == [first.id, second.id]
    end

    test "list_orders/1 searches order number and customer name case-insensitively" do
      by_number = order_fixture(%{order_number: "ORD-FIND-ME"})
      by_name = order_fixture(%{customer_name: "Findley Smith"})
      _other = order_fixture(%{customer_name: "Someone Else"})

      assert ids(Fulfillment.list_orders(%{"search" => "find"})) == [by_number.id, by_name.id]
    end

    test "list_orders/1 treats LIKE wildcards in search as literal text" do
      order_fixture(%{customer_name: "Plain Name"})
      assert ids(Fulfillment.list_orders(%{"search" => "%"})) == []
    end

    test "list_orders/1 filters by status and ignores unknown statuses" do
      picking = order_fixture(%{status: "picking"})
      received = order_fixture(%{status: "received"})

      assert ids(Fulfillment.list_orders(%{"status" => "picking"})) == [picking.id]

      assert ids(Fulfillment.list_orders(%{"status" => "bogus"})) == [
               picking.id,
               received.id
             ]
    end

    test "list_orders/1 sorts status in pipeline order, both directions" do
      shipping = order_fixture(%{status: "shipping"})
      received = order_fixture(%{status: "received"})
      exception = order_fixture(%{status: "exception"})

      asc = %{"sort" => "status", "dir" => "asc"}
      desc = %{"sort" => "status", "dir" => "desc"}

      assert ids(Fulfillment.list_orders(asc)) == [received.id, shipping.id, exception.id]
      assert ids(Fulfillment.list_orders(desc)) == [exception.id, shipping.id, received.id]
    end

    test "list_orders/1 sorts priority by urgency" do
      overnight = order_fixture(%{priority: "overnight"})
      standard = order_fixture(%{priority: "standard"})
      expedited = order_fixture(%{priority: "expedited"})

      assert ids(Fulfillment.list_orders(%{"sort" => "priority", "dir" => "asc"})) ==
               [standard.id, expedited.id, overnight.id]
    end

    test "list_orders/1 sorts by customer name and ship date" do
      zed = order_fixture(%{customer_name: "Zed", estimated_ship_date: ~D[2026-01-01]})
      amy = order_fixture(%{customer_name: "Amy", estimated_ship_date: ~D[2026-12-31]})

      assert ids(Fulfillment.list_orders(%{"sort" => "customer_name", "dir" => "asc"})) ==
               [amy.id, zed.id]

      assert ids(Fulfillment.list_orders(%{"sort" => "estimated_ship_date", "dir" => "desc"})) ==
               [amy.id, zed.id]
    end

    test "list_orders/1 ignores unknown sort fields" do
      first = order_fixture()
      second = order_fixture()

      assert ids(Fulfillment.list_orders(%{"sort" => "notes", "dir" => "desc"})) ==
               [first.id, second.id]
    end

    test "list_orders/1 sorts across pages, not just within one" do
      for _ <- 1..20, do: order_fixture(%{status: "received"})
      last_inserted = order_fixture(%{status: "exception"})

      page = Fulfillment.list_orders(%{"sort" => "status", "dir" => "desc"})
      assert page.total_pages == 2
      assert hd(page.entries).id == last_inserted.id
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

  defp ids(page), do: Enum.map(page.entries, & &1.id)
end
