defmodule FulfillmentPipeline.Repo.Migrations.AddWarehouseForeignKeyToOrders do
  use Ecto.Migration

  def change do
    alter table(:orders) do
      modify :warehouse_id, references(:warehouses, on_delete: :restrict)
    end
  end
end
