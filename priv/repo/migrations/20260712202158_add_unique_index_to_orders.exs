defmodule FulfillmentPipeline.Repo.Migrations.AddUniqueIndexToOrders do
  use Ecto.Migration

  def change do
    create unique_index(:orders, [:order_number])
  end
end
