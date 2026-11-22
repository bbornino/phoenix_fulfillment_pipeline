defmodule FulfillmentPipelineWeb.OrderHTML do
  use FulfillmentPipelineWeb, :html

  embed_templates "order_html/*"

  def status_color("received"), do: "color: #6b7280"
  def status_color("picking"), do: "color: #d97706"
  def status_color("packing"), do: "color: #d97706"
  def status_color("shipping"), do: "color: #2563eb"
  def status_color("delivered"), do: "color: #16a34a"
  def status_color("exception"), do: "color: #dc2626"
  def status_color(_), do: "color: #6b7280"

  @doc """
  Read-only label/value pair, sized to line up with the order form's inputs.
  """
  attr :label, :string, required: true
  attr :class, :any, default: nil
  slot :inner_block, required: true

  def detail(assigns) do
    ~H"""
    <div class={["mb-4", @class]}>
      <div class="text-sm text-base-content/60 mb-1">{@label}</div>
      <div class="min-h-10 px-3 py-2 rounded-md border border-base-300 bg-base-200/40">
        {render_slot(@inner_block)}
      </div>
    </div>
    """
  end
end
