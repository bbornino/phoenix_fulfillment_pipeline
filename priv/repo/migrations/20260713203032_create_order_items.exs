defmodule FulfillmentPipeline.Repo.Migrations.CreateOrderItems do
  use Ecto.Migration

  def change do
    create table(:order_items) do
      add :sku, :string
      add :description, :string
      add :quantity, :integer
      add :unit_price, :decimal
      add :weight_lbs, :decimal
      add :status, :string, default: "pending"
      add :order_id, references(:orders, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:order_items, [:order_id])
  end
end
