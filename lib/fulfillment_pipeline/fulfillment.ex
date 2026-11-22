defmodule FulfillmentPipeline.Fulfillment do
  @moduledoc """
  The Fulfillment context.
  """

  import Ecto.Query, warn: false
  alias FulfillmentPipeline.Repo

  alias FulfillmentPipeline.Fulfillment.Order

  @status_order ~w(received picking packing shipping delivered exception)
  @priority_order ~w(standard expedited overnight)

  @sort_fields %{
    "order_number" => :order_number,
    "customer_name" => :customer_name,
    "status" => :status,
    "priority" => :priority,
    "estimated_ship_date" => :estimated_ship_date
  }

  @doc """
  Returns the order statuses in pipeline order.
  """
  def order_statuses, do: @status_order

  @doc """
  Returns a page of orders.

  Accepts string-keyed params:

    * `"search"` - matches order number or customer name (case-insensitive)
    * `"status"` - exact status match
    * `"sort"` / `"dir"` - one of #{inspect(Map.keys(@sort_fields))}, and `"asc"` or `"desc"`.
      Status sorts in pipeline order and priority by urgency. Unsorted results are ordered by id.
    * `"page"` - page number (20 per page)

  ## Examples

      iex> list_orders(%{"status" => "picking", "sort" => "priority", "dir" => "desc"})
      %Scrivener.Page{entries: [%Order{}, ...]}

  """
  def list_orders(params \\ %{}) do
    Order
    |> filter_by_search(params["search"])
    |> filter_by_status(params["status"])
    |> sort_orders(params["sort"], params["dir"])
    |> preload([:warehouse, :carrier])
    |> Repo.paginate(params)
  end

  defp filter_by_search(query, search) when is_binary(search) and search != "" do
    pattern = "%" <> escape_like(String.trim(search)) <> "%"
    where(query, [o], ilike(o.order_number, ^pattern) or ilike(o.customer_name, ^pattern))
  end

  defp filter_by_search(query, _search), do: query

  defp filter_by_status(query, status) when status in @status_order,
    do: where(query, [o], o.status == ^status)

  defp filter_by_status(query, _status), do: query

  defp sort_orders(query, field, dir)
       when is_map_key(@sort_fields, field) and dir in ~w(asc desc) do
    direction = if dir == "asc", do: :asc, else: :desc

    query
    |> order_by(^[{direction, sort_expression(@sort_fields[field])}])
    |> order_by(asc: :id)
  end

  defp sort_orders(query, _field, _dir), do: order_by(query, asc: :id)

  defp sort_expression(:status),
    do: dynamic([o], fragment("array_position(?::text[], ?::text)", ^@status_order, o.status))

  defp sort_expression(:priority),
    do: dynamic([o], fragment("array_position(?::text[], ?::text)", ^@priority_order, o.priority))

  defp sort_expression(field), do: dynamic([o], field(o, ^field))

  defp escape_like(text), do: String.replace(text, ~r/[\\%_]/, "\\\\\\0")

  def list_active_orders do
    import Ecto.Query

    Order
    |> where([o], o.status != "delivered")
    |> Repo.all()
  end

  @doc """
  Gets a single order.

  Raises `Ecto.NoResultsError` if the Order does not exist.

  ## Examples

      iex> get_order!(123)
      %Order{}

      iex> get_order!(456)
      ** (Ecto.NoResultsError)

  """
  def get_order!(id) do
    Order
    |> Repo.get!(id)
    |> Repo.preload([:warehouse, :carrier])
  end

  def get_order_for_server!(id) do
    Repo.get!(Order, id)
  end

  @doc """
  Creates a order.

  ## Examples

      iex> create_order(%{field: value})
      {:ok, %Order{}}

      iex> create_order(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_order(attrs) do
    %Order{}
    |> Order.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a order.

  ## Examples

      iex> update_order(order, %{field: new_value})
      {:ok, %Order{}}

      iex> update_order(order, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_order(%Order{} = order, attrs) do
    order
    |> Order.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a order.

  ## Examples

      iex> delete_order(order)
      {:ok, %Order{}}

      iex> delete_order(order)
      {:error, %Ecto.Changeset{}}

  """
  def delete_order(%Order{} = order) do
    Repo.delete(order)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking order changes.

  ## Examples

      iex> change_order(order)
      %Ecto.Changeset{data: %Order{}}

  """
  def change_order(%Order{} = order, attrs \\ %{}) do
    Order.changeset(order, attrs)
  end
end
