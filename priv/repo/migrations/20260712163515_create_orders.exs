defmodule FulfillmentPipeline.Repo.Migrations.CreateOrders do
  use Ecto.Migration

  def change do
    create table(:orders) do
      add :order_number, :string
      add :customer_name, :string
      add :customer_email, :string
      add :status, :string, default: "received"
      add :priority, :string
      add :notes, :text
      add :requires_signature, :boolean, default: false, null: false
      add :estimated_ship_date, :date
      add :warehouse_id, :integer
      add :items, :map

      timestamps(type: :utc_datetime)
    end
  end
end
