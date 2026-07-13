defmodule FulfillmentPipelineWeb.PageControllerTest do
  use FulfillmentPipelineWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert redirected_to(conn) == ~p"/pipeline"
  end
end
