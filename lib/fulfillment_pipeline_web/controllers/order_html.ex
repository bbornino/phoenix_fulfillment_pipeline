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
end
