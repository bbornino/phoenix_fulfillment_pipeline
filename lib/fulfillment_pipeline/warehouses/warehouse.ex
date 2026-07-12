defmodule FulfillmentPipeline.Warehouses.Warehouse do
  use Ecto.Schema
  import Ecto.Changeset

  schema "warehouses" do
    field :name, :string
    field :city, :string
    field :state, :string
    field :zip, :string
    field :capacity, :integer
    field :active, :boolean, default: false
    field :manager_name, :string
    field :manager_email, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(warehouse, attrs) do
    warehouse
    |> cast(attrs, [:name, :city, :state, :zip, :capacity, :active, :manager_name, :manager_email])
    |> validate_required([:name, :city, :state, :zip, :capacity, :active, :manager_name, :manager_email])
  end
end
