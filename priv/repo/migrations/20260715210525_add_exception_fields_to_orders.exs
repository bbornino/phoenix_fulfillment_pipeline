defmodule FulfillmentPipeline.Repo.Migrations.AddExceptionFieldsToOrders do
  use Ecto.Migration

  def change do
    alter table(:orders) do
      add :exception_analysis, :text
      add :exception_raised_at, :utc_datetime
    end
  end
end
