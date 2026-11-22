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
    # Wait for the process to initialize
    Process.sleep(100)
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

  test "order number links to the edit page", %{conn: conn, order: order} do
    {:ok, view, _html} = live(conn, ~p"/pipeline")

    assert {:error, {:live_redirect, %{to: path}}} =
             view |> element("#order-link-#{order.id}") |> render_click()

    assert path == ~p"/orders/#{order.id}/edit"
  end

  describe "filters" do
    test "search narrows the table and updates the URL", %{conn: conn, order: order} do
      other = order_fixture(%{customer_name: "Zelda Quill"})
      {:ok, view, _html} = live(conn, ~p"/pipeline")

      view |> form("#order-filters", %{search: "zelda"}) |> render_change()

      assert_patch(view, ~p"/pipeline?#{%{search: "zelda"}}")
      assert has_element?(view, "#order-row-#{other.id}")
      refute has_element?(view, "#order-row-#{order.id}")
    end

    test "status filter narrows the table", %{conn: conn, order: order} do
      picking = order_fixture(%{status: "picking"})
      {:ok, view, _html} = live(conn, ~p"/pipeline")

      view |> form("#order-filters", %{status: "picking"}) |> render_change()

      assert has_element?(view, "#order-row-#{picking.id}")
      refute has_element?(view, "#order-row-#{order.id}")
    end

    test "shows an empty state when nothing matches", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/pipeline?search=no-such-order")
      assert has_element?(view, "#no-orders")
    end
  end

  describe "sorting" do
    test "header cycles unsorted -> asc -> desc -> unsorted", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/pipeline")
      refute has_element?(view, "#sort-status .hero-arrow-up")
      refute has_element?(view, "#sort-status .hero-arrow-down")

      view |> element("#sort-status") |> render_click()
      assert_patch(view, ~p"/pipeline?#{%{dir: "asc", sort: "status"}}")
      assert has_element?(view, "#sort-status .hero-arrow-up")

      view |> element("#sort-status") |> render_click()
      assert_patch(view, ~p"/pipeline?#{%{dir: "desc", sort: "status"}}")
      assert has_element?(view, "#sort-status .hero-arrow-down")

      view |> element("#sort-status") |> render_click()
      assert_patch(view, ~p"/pipeline")
      refute has_element?(view, "#sort-status .hero-arrow-up")
      refute has_element?(view, "#sort-status .hero-arrow-down")
    end

    test "only the sorted column shows an arrow", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/pipeline?sort=priority&dir=asc")
      assert has_element?(view, "#sort-priority .hero-arrow-up")
      refute has_element?(view, "#sort-customer_name .hero-arrow-up")
    end

    test "sorting keeps the current search", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/pipeline?search=ORD")

      view |> element("#sort-customer_name") |> render_click()
      assert_patch(view, ~p"/pipeline?#{%{dir: "asc", search: "ORD", sort: "customer_name"}}")
    end
  end

  describe "pagination" do
    test "shows page summary and moves between pages", %{conn: conn, order: first} do
      for _ <- 1..20, do: order_fixture()

      {:ok, view, _html} = live(conn, ~p"/pipeline")
      assert view |> element("#page-summary") |> render() =~ "Page 1 of 2"
      assert view |> element("#page-summary") |> render() =~ "21 orders"
      assert has_element?(view, "#order-row-#{first.id}")
      refute has_element?(view, "#prev-page")

      view |> element("#next-page") |> render_click()
      assert_patch(view, ~p"/pipeline?#{%{page: 2}}")
      assert view |> element("#page-summary") |> render() =~ "Page 2 of 2"
      refute has_element?(view, "#order-row-#{first.id}")
      refute has_element?(view, "#next-page")
      assert has_element?(view, "#prev-page")
    end

    test "changing a filter resets to page 1", %{conn: conn} do
      for _ <- 1..20, do: order_fixture()
      {:ok, view, _html} = live(conn, ~p"/pipeline?page=2")

      view |> form("#order-filters", %{status: "received"}) |> render_change()
      assert_patch(view, ~p"/pipeline?#{%{status: "received"}}")
    end
  end
end
