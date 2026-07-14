defmodule FulfillmentPipeline.Repo.Migrations.CreateCarriers do
  use Ecto.Migration

  def change do
    create table(:carriers) do
      add :name, :string
      add :code, :string
      add :active, :boolean, default: true, null: false
      add :max_weight_lbs, :decimal
      add :tracking_url_template, :string

      timestamps(type: :utc_datetime)
    end

    create unique_index(:carriers, [:code])
  end
end
