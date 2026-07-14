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
    field :warehouse_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(inventory_item, attrs) do
    inventory_item
    |> cast(attrs, [:sku, :description, :quantity_on_hand, :quantity_reserved, :reorder_point, :unit_cost])
    |> validate_required([:sku, :description, :quantity_on_hand, :quantity_reserved, :reorder_point, :unit_cost])
  end
end
