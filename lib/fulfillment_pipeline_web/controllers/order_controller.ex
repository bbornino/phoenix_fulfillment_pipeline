defmodule FulfillmentPipelineWeb.OrderController do
  use FulfillmentPipelineWeb, :controller

  alias FulfillmentPipeline.Fulfillment
  alias FulfillmentPipeline.Fulfillment.Order

  def index(conn, _params) do
    orders = Fulfillment.list_orders()
    render(conn, :index, orders: orders)
  end

  def new(conn, _params) do
    changeset = Fulfillment.change_order(%Order{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"order" => order_params}) do
    case Fulfillment.create_order(order_params) do
      {:ok, order} ->
        conn
        |> put_flash(:info, "Order created successfully.")
        |> redirect(to: ~p"/orders/#{order}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    order = Fulfillment.get_order!(id)
    render(conn, :show, order: order)
  end

  def edit(conn, %{"id" => id}) do
    order = Fulfillment.get_order!(id)
    changeset = Fulfillment.change_order(order)
    render(conn, :edit, order: order, changeset: changeset)
  end

  def update(conn, %{"id" => id, "order" => order_params}) do
    order = Fulfillment.get_order!(id)

    case Fulfillment.update_order(order, order_params) do
      {:ok, order} ->
        conn
        |> put_flash(:info, "Order updated successfully.")
        |> redirect(to: ~p"/orders/#{order}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, order: order, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    order = Fulfillment.get_order!(id)
    {:ok, _order} = Fulfillment.delete_order(order)

    conn
    |> put_flash(:info, "Order deleted successfully.")
    |> redirect(to: ~p"/orders")
  end
end
