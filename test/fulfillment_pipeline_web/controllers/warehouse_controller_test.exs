defmodule FulfillmentPipelineWeb.WarehouseControllerTest do
  use FulfillmentPipelineWeb.ConnCase

  import FulfillmentPipeline.WarehousesFixtures

  @create_attrs %{active: true, name: "some name", state: "some state", zip: "some zip", city: "some city", capacity: 42, manager_name: "some manager_name", manager_email: "some manager_email"}
  @update_attrs %{active: false, name: "some updated name", state: "some updated state", zip: "some updated zip", city: "some updated city", capacity: 43, manager_name: "some updated manager_name", manager_email: "some updated manager_email"}
  @invalid_attrs %{active: nil, name: nil, state: nil, zip: nil, city: nil, capacity: nil, manager_name: nil, manager_email: nil}

  describe "index" do
    test "lists all warehouses", %{conn: conn} do
      conn = get(conn, ~p"/warehouses")
      assert html_response(conn, 200) =~ "Listing Warehouses"
    end
  end

  describe "new warehouse" do
    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/warehouses/new")
      assert html_response(conn, 200) =~ "New Warehouse"
    end
  end

  describe "create warehouse" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/warehouses", warehouse: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/warehouses/#{id}"

      conn = get(conn, ~p"/warehouses/#{id}")
      assert html_response(conn, 200) =~ "Warehouse #{id}"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/warehouses", warehouse: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Warehouse"
    end
  end

  describe "edit warehouse" do
    setup [:create_warehouse]

    test "renders form for editing chosen warehouse", %{conn: conn, warehouse: warehouse} do
      conn = get(conn, ~p"/warehouses/#{warehouse}/edit")
      assert html_response(conn, 200) =~ "Edit Warehouse"
    end
  end

  describe "update warehouse" do
    setup [:create_warehouse]

    test "redirects when data is valid", %{conn: conn, warehouse: warehouse} do
      conn = put(conn, ~p"/warehouses/#{warehouse}", warehouse: @update_attrs)
      assert redirected_to(conn) == ~p"/warehouses/#{warehouse}"

      conn = get(conn, ~p"/warehouses/#{warehouse}")
      assert html_response(conn, 200) =~ "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn, warehouse: warehouse} do
      conn = put(conn, ~p"/warehouses/#{warehouse}", warehouse: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Warehouse"
    end
  end

  describe "delete warehouse" do
    setup [:create_warehouse]

    test "deletes chosen warehouse", %{conn: conn, warehouse: warehouse} do
      conn = delete(conn, ~p"/warehouses/#{warehouse}")
      assert redirected_to(conn) == ~p"/warehouses"

      assert_error_sent 404, fn ->
        get(conn, ~p"/warehouses/#{warehouse}")
      end
    end
  end

  defp create_warehouse(_) do
    warehouse = warehouse_fixture()

    %{warehouse: warehouse}
  end
end
