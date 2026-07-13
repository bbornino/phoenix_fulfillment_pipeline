defmodule FulfillmentPipeline.Repo.Migrations.RemoveItemsFromOrders do
  use Ecto.Migration

  def change do
    alter table(:orders) do
      remove :items
    end
  end
end
