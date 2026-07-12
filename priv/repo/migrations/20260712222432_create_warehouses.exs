defmodule FulfillmentPipeline.Repo.Migrations.CreateWarehouses do
  use Ecto.Migration

  def change do
    create table(:warehouses) do
      add :name, :string
      add :city, :string
      add :state, :string
      add :zip, :string
      add :capacity, :integer
      add :active, :boolean, default: false, null: false
      add :manager_name, :string
      add :manager_email, :string

      timestamps(type: :utc_datetime)
    end
  end
end
