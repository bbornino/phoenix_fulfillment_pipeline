defmodule FulfillmentPipelineWeb.WarehouseController do
  use FulfillmentPipelineWeb, :controller

  alias FulfillmentPipeline.Warehouses
  alias FulfillmentPipeline.Warehouses.Warehouse

  def index(conn, _params) do
    warehouses = Warehouses.list_warehouses()
    render(conn, :index, warehouses: warehouses)
  end

  def new(conn, _params) do
    changeset = Warehouses.change_warehouse(%Warehouse{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"warehouse" => warehouse_params}) do
    case Warehouses.create_warehouse(warehouse_params) do
      {:ok, warehouse} ->
        conn
        |> put_flash(:info, "Warehouse created successfully.")
        |> redirect(to: ~p"/warehouses/#{warehouse}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    warehouse = Warehouses.get_warehouse!(id)
    render(conn, :show, warehouse: warehouse)
  end

  def edit(conn, %{"id" => id}) do
    warehouse = Warehouses.get_warehouse!(id)
    changeset = Warehouses.change_warehouse(warehouse)
    render(conn, :edit, warehouse: warehouse, changeset: changeset)
  end

  def update(conn, %{"id" => id, "warehouse" => warehouse_params}) do
    warehouse = Warehouses.get_warehouse!(id)

    case Warehouses.update_warehouse(warehouse, warehouse_params) do
      {:ok, warehouse} ->
        conn
        |> put_flash(:info, "Warehouse updated successfully.")
        |> redirect(to: ~p"/warehouses/#{warehouse}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, warehouse: warehouse, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    warehouse = Warehouses.get_warehouse!(id)
    {:ok, _warehouse} = Warehouses.delete_warehouse(warehouse)

    conn
    |> put_flash(:info, "Warehouse deleted successfully.")
    |> redirect(to: ~p"/warehouses")
  end
end
