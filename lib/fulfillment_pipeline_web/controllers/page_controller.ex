defmodule FulfillmentPipelineWeb.PageController do
  use FulfillmentPipelineWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
