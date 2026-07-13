defmodule FulfillmentPipelineWeb.PageController do
  use FulfillmentPipelineWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end

  def redirect_to_pipeline(conn, _params) do
    redirect(conn, to: ~p"/pipeline")
  end
end
