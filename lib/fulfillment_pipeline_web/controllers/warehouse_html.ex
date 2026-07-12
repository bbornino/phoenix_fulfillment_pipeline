defmodule FulfillmentPipelineWeb.WarehouseHTML do
  use FulfillmentPipelineWeb, :html

  embed_templates "warehouse_html/*"

  @doc """
  Renders a warehouse form.

  The form is defined in the template at
  warehouse_html/warehouse_form.html.heex
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true
  attr :return_to, :string, default: nil

  def warehouse_form(assigns)
end
