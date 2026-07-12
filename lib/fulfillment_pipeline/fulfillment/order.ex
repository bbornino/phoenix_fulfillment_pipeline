defmodule FulfillmentPipeline.Fulfillment.Order do
  use Ecto.Schema
  import Ecto.Changeset

  schema "orders" do
    field :order_number, :string
    field :customer_name, :string
    field :customer_email, :string
    field :status, :string
    field :priority, :string
    field :notes, :string
    field :requires_signature, :boolean, default: false
    field :estimated_ship_date, :date
    field :warehouse_id, :integer
    field :items, :map

    belongs_to :warehouse, FulfillmentPipeline.Warehouses.Warehouse, define_field: false

    timestamps(type: :utc_datetime)
  end

  @valid_statuses ~w(received picking packing shipping delivered exception)
  @valid_priorities ~w(standard expedited overnight)

  @doc false
  def changeset(order, attrs) do
    order
    |> cast(attrs, [
      :order_number,
      :customer_name,
      :customer_email,
      :status,
      :priority,
      :notes,
      :requires_signature,
      :estimated_ship_date,
      :warehouse_id,
      :items
    ])
    |> validate_required([
      :order_number,
      :customer_name,
      :customer_email,
      :status,
      :priority,
      :estimated_ship_date,
      :warehouse_id
    ])
    |> validate_inclusion(:status, @valid_statuses)
    |> validate_inclusion(:priority, @valid_priorities)
    |> validate_format(:customer_email, ~r/^[^\s]+@[^\s]+\.[^\s]+$/)
    |> unique_constraint(:order_number)
  end
end
