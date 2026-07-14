defmodule FulfillmentPipeline.Inventory do
  @moduledoc """
  The Inventory context.
  """

  import Ecto.Query, warn: false
  alias FulfillmentPipeline.Repo

  alias FulfillmentPipeline.Inventory.InventoryItem

  @doc """
  Returns the list of inventory_items.

  ## Examples

      iex> list_inventory_items()
      [%InventoryItem{}, ...]

  """
  def list_inventory_items do
    Repo.all(InventoryItem)
  end

  def list_inventory_items_for_warehouse(warehouse_id) do
    InventoryItem
    |> where([i], i.warehouse_id == ^warehouse_id)
    |> order_by([i], i.sku)
    |> Repo.all()
  end

  def get_inventory_item_by_sku(warehouse_id, sku) do
    Repo.get_by(InventoryItem, warehouse_id: warehouse_id, sku: sku)
  end

  def low_stock_items do
    InventoryItem
    |> where([i], i.quantity_on_hand <= i.reorder_point)
    |> preload(:warehouse)
    |> Repo.all()
  end

  @doc """
  Gets a single inventory_item.

  Raises `Ecto.NoResultsError` if the Inventory item does not exist.

  ## Examples

      iex> get_inventory_item!(123)
      %InventoryItem{}

      iex> get_inventory_item!(456)
      ** (Ecto.NoResultsError)

  """
  def get_inventory_item!(id), do: Repo.get!(InventoryItem, id)

  @doc """
  Creates a inventory_item.

  ## Examples

      iex> create_inventory_item(%{field: value})
      {:ok, %InventoryItem{}}

      iex> create_inventory_item(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_inventory_item(attrs) do
    %InventoryItem{}
    |> InventoryItem.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a inventory_item.

  ## Examples

      iex> update_inventory_item(inventory_item, %{field: new_value})
      {:ok, %InventoryItem{}}

      iex> update_inventory_item(inventory_item, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_inventory_item(%InventoryItem{} = inventory_item, attrs) do
    inventory_item
    |> InventoryItem.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a inventory_item.

  ## Examples

      iex> delete_inventory_item(inventory_item)
      {:ok, %InventoryItem{}}

      iex> delete_inventory_item(inventory_item)
      {:error, %Ecto.Changeset{}}

  """
  def delete_inventory_item(%InventoryItem{} = inventory_item) do
    Repo.delete(inventory_item)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking inventory_item changes.

  ## Examples

      iex> change_inventory_item(inventory_item)
      %Ecto.Changeset{data: %InventoryItem{}}

  """
  def change_inventory_item(%InventoryItem{} = inventory_item, attrs \\ %{}) do
    InventoryItem.changeset(inventory_item, attrs)
  end
end
