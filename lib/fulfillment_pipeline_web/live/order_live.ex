defmodule FulfillmentPipelineWeb.OrderLive do
  use FulfillmentPipelineWeb, :live_view

  alias FulfillmentPipeline.Fulfillment
  alias FulfillmentPipeline.Order.Server
  alias FulfillmentPipeline.Order.ExceptionAnalyzer

  @filter_keys ~w(search status sort dir page)

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(FulfillmentPipeline.PubSub, "orders")
    end

    {:ok, assign(socket, statuses: Fulfillment.order_statuses())}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    filters = Map.take(params, @filter_keys)
    page = Fulfillment.list_orders(filters)

    {:noreply,
     assign(socket,
       orders: page.entries,
       page: page,
       filters: filters,
       filter_form: to_form(Map.take(filters, ~w(search status)))
     )}
  end

  @impl true
  def handle_info({:order_updated, updated_order}, socket) do
    orders =
      Enum.map(socket.assigns.orders, fn order ->
        if order.id == updated_order.id, do: updated_order, else: order
      end)

    {:noreply, assign(socket, orders: orders)}
  end

  @impl true
  def handle_info({:exception_analyzed, order_id, analysis}, socket) do
    orders =
      Enum.map(socket.assigns.orders, fn order ->
        if order.id == order_id do
          %{order | exception_analysis: analysis}
        else
          order
        end
      end)

    {:noreply, assign(socket, orders: orders)}
  end

  @impl true
  def handle_event("advance", %{"id" => id}, socket) do
    Server.advance(String.to_integer(id))
    {:noreply, socket}
  end

  @impl true
  def handle_event("trigger_exception", %{"id" => id}, socket) do
    Server.trigger_exception(String.to_integer(id))
    {:noreply, socket}
  end

  @impl true
  def handle_event("analyze_exception", %{"id" => id}, socket) do
    order_id = String.to_integer(id)

    # Mark as analyzing in the UI immediately
    orders =
      Enum.map(socket.assigns.orders, fn order ->
        if order.id == order_id do
          %{order | exception_analysis: "Analyzing..."}
        else
          order
        end
      end)

    # Kick off Claude analysis as a supervised Task
    Task.Supervisor.start_child(FulfillmentPipeline.TaskSupervisor, fn ->
      ExceptionAnalyzer.analyze(order_id)
    end)

    {:noreply, assign(socket, orders: orders)}
  end

  @impl true
  def handle_event("filter", params, socket) do
    filters =
      socket.assigns.filters
      |> Map.merge(Map.take(params, ~w(search status)))
      |> Map.delete("page")

    {:noreply, push_patch(socket, to: pipeline_path(filters))}
  end

  attr :field, :string, required: true
  attr :label, :string, required: true
  attr :filters, :map, required: true

  defp sort_header(assigns) do
    assigns = assign(assigns, :dir, sort_dir(assigns.filters, assigns.field))

    ~H"""
    <.link
      id={"sort-#{@field}"}
      patch={pipeline_path(next_sort(@filters, @field))}
      class="inline-flex items-center gap-1 hover:text-blue-600"
    >
      {@label}
      <.icon :if={@dir == "asc"} name="hero-arrow-up" class="size-3" />
      <.icon :if={@dir == "desc"} name="hero-arrow-down" class="size-3" />
    </.link>
    """
  end

  defp sort_dir(%{"sort" => field, "dir" => dir}, field), do: dir
  defp sort_dir(_filters, _field), do: nil

  # Cycles a column: unsorted -> asc -> desc -> unsorted. Changing sort resets to page 1.
  defp next_sort(filters, field) do
    base = Map.drop(filters, ~w(sort dir page))

    case sort_dir(filters, field) do
      "asc" -> Map.merge(base, %{"sort" => field, "dir" => "desc"})
      "desc" -> base
      _ -> Map.merge(base, %{"sort" => field, "dir" => "asc"})
    end
  end

  defp page_link(filters, page_number), do: pipeline_path(Map.put(filters, "page", page_number))

  defp pipeline_path(filters) do
    query = Map.reject(filters, fn {_key, value} -> value in [nil, ""] end)

    if query == %{}, do: ~p"/pipeline", else: ~p"/pipeline?#{query}"
  end

  defp status_color("received"), do: "#888"
  defp status_color("picking"), do: "#f59e0b"
  defp status_color("packing"), do: "#f59e0b"
  defp status_color("shipping"), do: "#3b82f6"
  defp status_color("delivered"), do: "#22c55e"
  defp status_color("exception"), do: "#ef4444"
  defp status_color(_), do: "#888"
end
