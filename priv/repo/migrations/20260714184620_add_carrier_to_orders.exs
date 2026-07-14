defmodule FulfillmentPipeline.Repo.Migrations.AddCarrierToOrders do
  use Ecto.Migration

  def change do
    alter table(:orders) do
      add :carrier_id, references(:carriers, on_delete: :nilify_all)
      add :tracking_number, :string
    end

    create index(:orders, [:carrier_id])
  end
end
