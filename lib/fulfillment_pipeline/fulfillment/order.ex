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
    field :tracking_number, :string
    field :exception_analysis, :string
    field :exception_raised_at, :utc_datetime

    belongs_to :warehouse, FulfillmentPipeline.Warehouses.Warehouse
    belongs_to :carrier, FulfillmentPipeline.Carriers.Carrier
    has_many :order_items, FulfillmentPipeline.OrderItems.OrderItem

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
      :carrier_id,
      :tracking_number,
      :exception_analysis,
      :exception_raised_at
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
