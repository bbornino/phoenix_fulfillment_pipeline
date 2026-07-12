defmodule FulfillmentPipeline.Order.ServerTest do
  use FulfillmentPipeline.DataCase

  alias FulfillmentPipeline.Order.Server
  alias FulfillmentPipeline.Order.Supervisor, as: OrderSupervisor
  import FulfillmentPipeline.FulfillmentFixtures

  test "starts with correct initial state" do
    order = order_fixture()
    OrderSupervisor.start_order(order.id)

    state = Server.get_state(order.id)
    assert state.status == "received"
    assert state.order_number == order.order_number
  end

  test "advances through pipeline stages" do
    order = order_fixture()
    OrderSupervisor.start_order(order.id)

    Server.advance(order.id)
    assert Server.get_state(order.id).status == "picking"

    Server.advance(order.id)
    assert Server.get_state(order.id).status == "packing"

    Server.advance(order.id)
    assert Server.get_state(order.id).status == "shipping"

    Server.advance(order.id)
    assert Server.get_state(order.id).status == "delivered"

    Server.advance(order.id)
    assert Server.get_state(order.id).status == "delivered"
  end

  test "triggers exception" do
    order = order_fixture()
    OrderSupervisor.start_order(order.id)

    Server.trigger_exception(order.id)
    assert Server.get_state(order.id).status == "exception"
  end

  test "supervisor restarts crashed order process" do
    order = order_fixture()
    OrderSupervisor.start_order(order.id)

    [{original_pid, _}] = Registry.lookup(FulfillmentPipeline.Order.Registry, order.id)
    assert Process.alive?(original_pid)

    Process.exit(original_pid, :kill)
    Process.sleep(50)

    [{new_pid, _}] = Registry.lookup(FulfillmentPipeline.Order.Registry, order.id)
    assert Process.alive?(new_pid)
    assert new_pid != original_pid
    assert Server.get_state(order.id).status == "received"
  end
end
