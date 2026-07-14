defmodule FulfillmentPipeline.Repo.Migrations.CreateInventoryItems do
  use Ecto.Migration

  def change do
    create table(:inventory_items) do
      add :sku, :string
      add :description, :string
      add :quantity_on_hand, :integer, default: 0
      add :quantity_reserved, :integer, default: 0
      add :reorder_point, :integer, default: 0
      add :unit_cost, :decimal
      add :warehouse_id, references(:warehouses, on_delete: :restrict)

      timestamps(type: :utc_datetime)
    end

    create index(:inventory_items, [:warehouse_id])
    create unique_index(:inventory_items, [:warehouse_id, :sku])
  end
end
