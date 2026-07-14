defmodule FulfillmentPipeline.Inventory.InventoryItem do
  use Ecto.Schema
  import Ecto.Changeset

  schema "inventory_items" do
    field :sku, :string
    field :description, :string
    field :quantity_on_hand, :integer
    field :quantity_reserved, :integer
    field :reorder_point, :integer
    field :unit_cost, :decimal

    belongs_to :warehouse, FulfillmentPipeline.Warehouses.Warehouse

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(inventory_item, attrs) do
    inventory_item
    |> cast(attrs, [
      :sku,
      :description,
      :quantity_on_hand,
      :quantity_reserved,
      :reorder_point,
      :unit_cost,
      :warehouse_id
    ])
    |> validate_required([
      :sku,
      :description,
      :quantity_on_hand,
      :quantity_reserved,
      :reorder_point,
      :unit_cost,
      :warehouse_id
    ])
    |> validate_number(:quantity_on_hand, greater_than_or_equal_to: 0)
    |> validate_number(:quantity_reserved, greater_than_or_equal_to: 0)
    |> validate_number(:reorder_point, greater_than_or_equal_to: 0)
    |> validate_number(:unit_cost, greater_than_or_equal_to: 0)
    |> foreign_key_constraint(:warehouse_id)
    |> unique_constraint(:sku, name: :inventory_items_warehouse_id_sku_index)
  end
end
