defmodule FulfillmentPipeline.OrderItems.OrderItem do
  use Ecto.Schema
  import Ecto.Changeset

  schema "order_items" do
    field :sku, :string
    field :description, :string
    field :quantity, :integer
    field :unit_price, :decimal
    field :weight_lbs, :decimal
    field :status, :string

    belongs_to :order, FulfillmentPipeline.Fulfillment.Order

    timestamps(type: :utc_datetime)
  end

  @valid_statuses ~w(pending picking picked packed shipped backordered exception)

  @doc false
  def changeset(order_item, attrs) do
    order_item
    |> cast(attrs, [:sku, :description, :quantity, :unit_price, :weight_lbs, :status, :order_id])
    |> validate_required([:sku, :description, :quantity, :unit_price, :weight_lbs, :order_id])
    |> validate_inclusion(:status, @valid_statuses)
    |> validate_number(:quantity, greater_than: 0)
    |> validate_number(:unit_price, greater_than_or_equal_to: 0)
    |> validate_number(:weight_lbs, greater_than_or_equal_to: 0)
    |> foreign_key_constraint(:order_id)
  end
end
