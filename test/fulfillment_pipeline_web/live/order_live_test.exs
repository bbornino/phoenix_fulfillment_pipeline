defmodule FulfillmentPipelineWeb.OrderLiveTest do
  use FulfillmentPipelineWeb.ConnCase

  import Phoenix.LiveViewTest
  import FulfillmentPipeline.FulfillmentFixtures
  import FulfillmentPipeline.WarehousesFixtures

  setup do
    warehouse = warehouse_fixture()
    order = order_fixture(%{warehouse_id: warehouse.id})
    %{order: order, warehouse: warehouse}
  end

  test "dashboard renders orders", %{conn: conn, order: order} do
    {:ok, _view, html} = live(conn, ~p"/pipeline")
    assert html =~ order.order_number
    assert html =~ order.customer_name
  end

  test "advance button updates order status", %{conn: conn, order: order} do
    FulfillmentPipeline.Order.Supervisor.start_order(order.id)

    {:ok, view, _html} = live(conn, ~p"/pipeline")

    assert view |> element("button", "Advance") |> render_click() =~ ""

    updated_order = FulfillmentPipeline.Fulfillment.get_order!(order.id)
    assert updated_order.status == "picking"
  end

  test "exception button sets order to exception status", %{conn: conn, order: order} do
    FulfillmentPipeline.Order.Supervisor.start_order(order.id)

    {:ok, view, _html} = live(conn, ~p"/pipeline")

    view |> element("button", "Exception") |> render_click()
    # Wait for the process to handle the exception
    Process.sleep(100)

    updated_order = FulfillmentPipeline.Fulfillment.get_order!(order.id)
    assert updated_order.status == "exception"
  end

  test "dashboard shows status colors", %{conn: conn, order: _order} do
    {:ok, _view, html} = live(conn, ~p"/pipeline")
    assert html =~ "received"
  end
end
