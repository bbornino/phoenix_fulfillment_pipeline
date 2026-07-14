defmodule FulfillmentPipeline.Carriers.Carrier do
  use Ecto.Schema
  import Ecto.Changeset

  schema "carriers" do
    field :name, :string
    field :code, :string
    field :active, :boolean, default: true
    field :max_weight_lbs, :decimal
    field :tracking_url_template, :string

    has_many :orders, FulfillmentPipeline.Fulfillment.Order

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(carrier, attrs) do
    carrier
    |> cast(attrs, [:name, :code, :active, :max_weight_lbs, :tracking_url_template])
    |> validate_required([:name, :code, :active, :max_weight_lbs])
    |> validate_length(:code, min: 2, max: 20)
    |> unique_constraint(:code)
  end
end
