defmodule FulfillmentPipeline.Order.ExceptionAnalyzer do
  @moduledoc """
  Analyzes exception orders using the Claude API.
  Provides root cause analysis, resolution options, and customer notification drafts.
  """

  alias FulfillmentPipeline.Fulfillment
  alias FulfillmentPipeline.Inventory
  alias FulfillmentPipeline.OrderItems

  def analyze(order_id) do
    order = Fulfillment.get_order!(order_id)
    order_items = OrderItems.list_order_items_for_order(order_id)
    inventory = fetch_inventory_context(order, order_items)

    prompt = build_prompt(order, order_items, inventory)

    client = Anthropix.init(api_key())

    case Anthropix.chat(client,
           model: "claude-sonnet-4-6",
           max_tokens: 1000,
           messages: [%{role: "user", content: prompt}]
         ) do
      {:ok, response} ->
        analysis = extract_text(response)
        Fulfillment.update_order(order, %{exception_analysis: analysis})

        Phoenix.PubSub.broadcast(
          FulfillmentPipeline.PubSub,
          "orders",
          {:exception_analyzed, order_id, analysis}
        )

        {:ok, analysis}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp fetch_inventory_context(order, order_items) do
    Enum.map(order_items, fn item ->
      inventory = Inventory.get_inventory_item_by_sku(order.warehouse_id, item.sku)
      {item.sku, inventory}
    end)
  end

  defp build_prompt(order, order_items, inventory) do
    warehouse_name = if order.warehouse, do: order.warehouse.name, else: "Unknown"
    carrier_name = if order.carrier, do: order.carrier.name, else: "Not assigned"

    exception_duration =
      if order.exception_raised_at do
        hours = DateTime.diff(DateTime.utc_now(), order.exception_raised_at, :hour)
        "#{hours} hours"
      else
        "Unknown duration"
      end

    items_text =
      Enum.map_join(order_items, "\n", fn item ->
        inv = Enum.find(inventory, fn {sku, _} -> sku == item.sku end)

        inv_status =
          case inv do
            {_, nil} ->
              "No inventory record found"

            {_, i} ->
              "On hand: #{i.quantity_on_hand}, Reserved: #{i.quantity_reserved}, Reorder point: #{i.reorder_point}"
          end

        "  - #{item.sku} #{item.description} x#{item.quantity} (#{inv_status})"
      end)

    """
    You are an expert fulfillment operations analyst for a warehouse management system.
    Analyze this exception order and provide actionable guidance.

    ORDER DETAILS:
    Order: #{order.order_number}
    Customer: #{order.customer_name} (#{order.customer_email})
    Priority: #{order.priority}
    Status: #{order.status}
    Warehouse: #{warehouse_name}
    Carrier: #{carrier_name}
    Estimated Ship Date: #{order.estimated_ship_date}
    Exception Duration: #{exception_duration}
    Exception Notes: #{order.notes || "None provided"}

    ORDER ITEMS AND INVENTORY:
    #{items_text}

    Please provide:
    1. ROOT CAUSE: What likely caused this exception based on the available information
    2. RESOLUTION OPTIONS: 2-3 concrete next steps to resolve this order
    3. CUSTOMER NOTIFICATION: A brief, professional message to send the customer
    4. PATTERN RISK: Is this likely an isolated incident or part of a larger pattern?

    Be concise and specific. Focus on actionable recommendations.
    """
  end

  defp extract_text(response) do
    response
    |> Map.get("content", [])
    |> Enum.filter(&(&1["type"] == "text"))
    |> Enum.map_join("\n", & &1["text"])
  end

  defp api_key do
    System.get_env("ANTHROPIC_API_KEY") ||
      raise "ANTHROPIC_API_KEY environment variable not set"
  end
end
