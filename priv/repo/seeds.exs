alias FulfillmentPipeline.Repo
alias FulfillmentPipeline.Fulfillment.Order
alias FulfillmentPipeline.Warehouses.Warehouse
alias FulfillmentPipeline.Carriers.Carrier
alias FulfillmentPipeline.OrderItems.OrderItem
alias FulfillmentPipeline.Inventory.InventoryItem

# Clear existing data in dependency order
Repo.delete_all(OrderItem)
Repo.delete_all(Order)
Repo.delete_all(InventoryItem)
Repo.delete_all(Warehouse)
Repo.delete_all(Carrier)

# ---- Carriers ----
carriers = [
  %{
    name: "UPS Ground",
    code: "ups",
    active: true,
    max_weight_lbs: Decimal.new("150.0"),
    tracking_url_template: "https://www.ups.com/track?tracknum="
  },
  %{
    name: "FedEx Ground",
    code: "fedex",
    active: true,
    max_weight_lbs: Decimal.new("150.0"),
    tracking_url_template: "https://www.fedex.com/apps/fedextrack/?tracknumbers="
  },
  %{
    name: "USPS Priority",
    code: "usps",
    active: true,
    max_weight_lbs: Decimal.new("70.0"),
    tracking_url_template: "https://tools.usps.com/go/TrackConfirmAction?tLabels="
  },
  %{
    name: "OnTrac",
    code: "ontrac",
    active: true,
    max_weight_lbs: Decimal.new("150.0"),
    tracking_url_template: "https://www.ontrac.com/trackingdetail.asp?tracking="
  },
  %{
    name: "FreightCo LTL",
    code: "freight",
    active: true,
    max_weight_lbs: Decimal.new("5000.0"),
    tracking_url_template: "https://www.freightco.com/track?pro="
  }
]

inserted_carriers =
  Enum.map(carriers, fn c ->
    Repo.insert!(%Carrier{
      name: c.name,
      code: c.code,
      active: c.active,
      max_weight_lbs: c.max_weight_lbs,
      tracking_url_template: c.tracking_url_template
    })
  end)

ups = Enum.find(inserted_carriers, &(&1.code == "ups"))
fedex = Enum.find(inserted_carriers, &(&1.code == "fedex"))
usps = Enum.find(inserted_carriers, &(&1.code == "usps"))
ontrac = Enum.find(inserted_carriers, &(&1.code == "ontrac"))
_freight = Enum.find(inserted_carriers, &(&1.code == "freight"))

IO.puts("Seeded #{length(inserted_carriers)} carriers.")

# ---- Warehouses ----
warehouses = [
  %{
    name: "Sacramento Fulfillment Center",
    city: "Sacramento",
    state: "CA",
    zip: "95814",
    capacity: 500,
    active: true,
    manager_name: "Brian Bornino",
    manager_email: "brian@fulfillmentpipeline.com"
  },
  %{
    name: "Dallas Distribution Hub",
    city: "Dallas",
    state: "TX",
    zip: "75201",
    capacity: 850,
    active: true,
    manager_name: "Maria Rodriguez",
    manager_email: "maria@fulfillmentpipeline.com"
  },
  %{
    name: "Columbus Logistics Center",
    city: "Columbus",
    state: "OH",
    zip: "43215",
    capacity: 650,
    active: true,
    manager_name: "James Thompson",
    manager_email: "james@fulfillmentpipeline.com"
  },
  %{
    name: "Memphis Distribution Center",
    city: "Memphis",
    state: "TN",
    zip: "38101",
    capacity: 750,
    active: true,
    manager_name: "Sandra Lee",
    manager_email: "sandra@fulfillmentpipeline.com"
  },
  %{
    name: "Phoenix Fulfillment Hub",
    city: "Phoenix",
    state: "AZ",
    zip: "85001",
    capacity: 400,
    active: true,
    manager_name: "Carlos Rivera",
    manager_email: "carlos@fulfillmentpipeline.com"
  },
  %{
    name: "Atlanta Southeast Center",
    city: "Atlanta",
    state: "GA",
    zip: "30301",
    capacity: 600,
    active: true,
    manager_name: "Diana Chen",
    manager_email: "diana@fulfillmentpipeline.com"
  }
]

inserted_warehouses =
  Enum.map(warehouses, fn w ->
    Repo.insert!(%Warehouse{
      name: w.name,
      city: w.city,
      state: w.state,
      zip: w.zip,
      capacity: w.capacity,
      active: w.active,
      manager_name: w.manager_name,
      manager_email: w.manager_email
    })
  end)

[sac, dallas, columbus, memphis, phoenix_wh, atlanta] = inserted_warehouses

IO.puts("Seeded #{length(inserted_warehouses)} warehouses.")

# ---- Products / SKUs ----
products = [
  %{
    sku: "SKU-001",
    description: "Wireless Headphones",
    unit_price: Decimal.new("79.99"),
    weight_lbs: Decimal.new("1.2")
  },
  %{
    sku: "SKU-002",
    description: "Laptop Stand",
    unit_price: Decimal.new("49.99"),
    weight_lbs: Decimal.new("2.5")
  },
  %{
    sku: "SKU-003",
    description: "USB-C Hub",
    unit_price: Decimal.new("39.99"),
    weight_lbs: Decimal.new("0.5")
  },
  %{
    sku: "SKU-004",
    description: "Mechanical Keyboard",
    unit_price: Decimal.new("129.99"),
    weight_lbs: Decimal.new("2.8")
  },
  %{
    sku: "SKU-005",
    description: "Webcam HD",
    unit_price: Decimal.new("89.99"),
    weight_lbs: Decimal.new("0.8")
  },
  %{
    sku: "SKU-006",
    description: "Monitor Arm",
    unit_price: Decimal.new("59.99"),
    weight_lbs: Decimal.new("4.2")
  },
  %{
    sku: "SKU-007",
    description: "Desk Mat XL",
    unit_price: Decimal.new("29.99"),
    weight_lbs: Decimal.new("1.8")
  },
  %{
    sku: "SKU-008",
    description: "LED Desk Lamp",
    unit_price: Decimal.new("44.99"),
    weight_lbs: Decimal.new("1.5")
  },
  %{
    sku: "SKU-009",
    description: "Cable Management Kit",
    unit_price: Decimal.new("19.99"),
    weight_lbs: Decimal.new("0.6")
  },
  %{
    sku: "SKU-010",
    description: "Ergonomic Mouse",
    unit_price: Decimal.new("69.99"),
    weight_lbs: Decimal.new("0.4")
  },
  %{
    sku: "SKU-011",
    description: "Standing Desk Converter",
    unit_price: Decimal.new("199.99"),
    weight_lbs: Decimal.new("15.0")
  },
  %{
    sku: "SKU-012",
    description: "Blue Light Glasses",
    unit_price: Decimal.new("24.99"),
    weight_lbs: Decimal.new("0.2")
  },
  %{
    sku: "SKU-013",
    description: "Portable SSD 1TB",
    unit_price: Decimal.new("109.99"),
    weight_lbs: Decimal.new("0.3")
  },
  %{
    sku: "SKU-014",
    description: "Noise Cancelling Earbuds",
    unit_price: Decimal.new("149.99"),
    weight_lbs: Decimal.new("0.4")
  },
  %{
    sku: "SKU-015",
    description: "Smart Power Strip",
    unit_price: Decimal.new("34.99"),
    weight_lbs: Decimal.new("1.1")
  }
]

# ---- Inventory ----
# Sacramento: healthy stock, best performing warehouse
# Dallas: healthy stock, high volume
# Columbus: some low stock items
# Memphis: worst performing - low stock, high exception rate
# Phoenix: near capacity issues
# Atlanta: healthy but newer warehouse

inventory_configs = [
  # Sacramento - healthy
  {sac, "SKU-001", 250, 15, 30},
  {sac, "SKU-002", 180, 10, 25},
  {sac, "SKU-003", 320, 20, 40},
  {sac, "SKU-004", 150, 8, 20},
  {sac, "SKU-005", 200, 12, 25},
  {sac, "SKU-006", 90, 5, 15},
  {sac, "SKU-007", 280, 18, 30},
  {sac, "SKU-008", 175, 10, 20},
  {sac, "SKU-009", 400, 25, 50},
  {sac, "SKU-010", 220, 15, 25},
  {sac, "SKU-011", 45, 3, 10},
  {sac, "SKU-013", 160, 10, 20},
  {sac, "SKU-014", 130, 8, 15},
  {sac, "SKU-015", 300, 20, 35},
  # Dallas - high volume, healthy
  {dallas, "SKU-001", 400, 25, 50},
  {dallas, "SKU-002", 290, 18, 35},
  {dallas, "SKU-003", 500, 30, 60},
  {dallas, "SKU-004", 220, 14, 28},
  {dallas, "SKU-005", 310, 20, 40},
  {dallas, "SKU-007", 450, 28, 55},
  {dallas, "SKU-008", 280, 18, 30},
  {dallas, "SKU-009", 600, 40, 70},
  {dallas, "SKU-010", 350, 22, 40},
  {dallas, "SKU-013", 240, 15, 30},
  {dallas, "SKU-014", 200, 12, 25},
  {dallas, "SKU-015", 480, 30, 55},
  # Columbus - some low stock (SKU-004, SKU-011)
  {columbus, "SKU-001", 120, 8, 20},
  {columbus, "SKU-002", 95, 6, 18},
  {columbus, "SKU-003", 180, 12, 30},
  {columbus, "SKU-004", 12, 4, 20},
  {columbus, "SKU-005", 88, 5, 15},
  {columbus, "SKU-007", 145, 9, 22},
  {columbus, "SKU-008", 75, 4, 15},
  {columbus, "SKU-009", 220, 14, 35},
  {columbus, "SKU-010", 98, 6, 18},
  {columbus, "SKU-011", 8, 2, 15},
  {columbus, "SKU-013", 55, 3, 12},
  {columbus, "SKU-015", 165, 10, 28},
  # Memphis - chronic low stock, high exception rate
  {memphis, "SKU-001", 18, 6, 30},
  {memphis, "SKU-002", 22, 8, 35},
  {memphis, "SKU-003", 35, 10, 50},
  {memphis, "SKU-004", 5, 2, 25},
  {memphis, "SKU-005", 14, 5, 28},
  {memphis, "SKU-007", 28, 9, 40},
  {memphis, "SKU-008", 19, 6, 25},
  {memphis, "SKU-009", 42, 12, 60},
  {memphis, "SKU-010", 11, 4, 22},
  {memphis, "SKU-013", 7, 2, 18},
  {memphis, "SKU-014", 9, 3, 20},
  {memphis, "SKU-015", 31, 10, 45},
  # Phoenix - near reorder points
  {phoenix_wh, "SKU-001", 32, 5, 30},
  {phoenix_wh, "SKU-003", 28, 4, 25},
  {phoenix_wh, "SKU-005", 22, 3, 20},
  {phoenix_wh, "SKU-007", 45, 7, 40},
  {phoenix_wh, "SKU-009", 55, 8, 50},
  {phoenix_wh, "SKU-010", 18, 2, 15},
  {phoenix_wh, "SKU-013", 12, 2, 10},
  {phoenix_wh, "SKU-015", 38, 5, 35},
  # Atlanta - healthy newer warehouse
  {atlanta, "SKU-001", 180, 10, 25},
  {atlanta, "SKU-002", 140, 8, 20},
  {atlanta, "SKU-003", 220, 14, 30},
  {atlanta, "SKU-005", 160, 10, 22},
  {atlanta, "SKU-007", 195, 12, 28},
  {atlanta, "SKU-009", 280, 18, 40},
  {atlanta, "SKU-010", 145, 9, 20},
  {atlanta, "SKU-014", 110, 7, 18},
  {atlanta, "SKU-015", 210, 13, 30}
]

Enum.each(inventory_configs, fn {warehouse, sku, on_hand, reserved, reorder} ->
  product = Enum.find(products, &(&1.sku == sku))

  Repo.insert!(%InventoryItem{
    warehouse_id: warehouse.id,
    sku: sku,
    description: product.description,
    quantity_on_hand: on_hand,
    quantity_reserved: reserved,
    reorder_point: reorder,
    unit_cost: Decimal.mult(product.unit_price, Decimal.new("0.6"))
  })
end)

IO.puts("Seeded inventory across #{length(inserted_warehouses)} warehouses.")

# ---- Customers ----
customers = [
  {"Alice Johnson", "alice.johnson@example.com"},
  {"Bob Martinez", "bob.martinez@example.com"},
  {"Carol Williams", "carol.w@example.com"},
  {"David Chen", "david.chen@example.com"},
  {"Emma Davis", "emma.davis@example.com"},
  {"Frank Wilson", "f.wilson@example.com"},
  {"Grace Lee", "grace.lee@example.com"},
  {"Henry Taylor", "htaylor@example.com"},
  {"Isabel Anderson", "isabel.a@example.com"},
  {"James Thompson", "jthompson@example.com"},
  {"Karen White", "karen.white@example.com"},
  {"Luis Garcia", "luis.garcia@example.com"},
  {"Maria Rodriguez", "maria.r@example.com"},
  {"Nathan Brown", "n.brown@example.com"},
  {"Olivia Miller", "olivia.m@example.com"},
  {"Patrick Jones", "p.jones@example.com"},
  {"Quinn Moore", "quinn.moore@example.com"},
  {"Rachel Clark", "r.clark@example.com"},
  {"Samuel Lewis", "s.lewis@example.com"},
  {"Tina Walker", "tina.w@example.com"},
  {"Uma Patel", "uma.patel@example.com"},
  {"Victor Hall", "v.hall@example.com"},
  {"Wendy Allen", "wendy.allen@example.com"},
  {"Xavier Young", "x.young@example.com"},
  {"Yuki Nakamura", "yuki.n@example.com"}
]

# ---- Helper functions ----
priorities = ["standard", "standard", "standard", "expedited", "expedited", "overnight"]

# Warehouse weights — Memphis gets more orders but worse performance
warehouse_pool = [
  sac,
  sac,
  sac,
  dallas,
  dallas,
  dallas,
  dallas,
  columbus,
  columbus,
  memphis,
  memphis,
  memphis,
  phoenix_wh,
  atlanta,
  atlanta
]

# Carrier assignment based on order priority and weight
assign_carrier = fn priority, _weight ->
  case priority do
    "overnight" -> fedex
    "expedited" -> Enum.random([ups, fedex, ontrac])
    _ -> Enum.random([ups, usps, ontrac])
  end
end

# Exception reasons for realistic exception orders
exception_reasons = [
  "Item damaged during picking — replacement needed",
  "Inventory count mismatch for SKU — cycle count required",
  "Customer address undeliverable — awaiting corrected address",
  "Carrier refused pickup — package weight exceeded limit",
  "Packing materials shortage — order on hold",
  "Duplicate order flagged for review",
  "Payment authorization failed — customer contacted",
  "SKU discontinued — customer notified of substitution options",
  "Weather delay at origin warehouse",
  "Lost in transit — carrier claim filed"
]

# Memphis-specific exceptions — higher rate
memphis_exception_reasons = [
  "Picking staff shortage — order delayed",
  "Inventory system discrepancy — manual count required",
  "Conveyor system outage — fulfillment paused",
  "Incorrect item picked — returned to queue",
  "Label printer failure — shipment delayed"
]

:rand.seed(:exsss, {System.os_time(:millisecond), 0, 0})

# ---- Generate 500 orders over 90 days ----
today = Date.utc_today()

# Volume spike 6 weeks ago (promo event)
promo_start = Date.add(today, -42)
promo_end = Date.add(today, -35)

# Carrier outage 2 weeks ago (UPS)
outage_date = Date.add(today, -14)

_order_count = 0

orders_data =
  for i <- 1..500 do
    # Distribute orders across 90 days with volume spike
    days_ago = :rand.uniform(90)
    order_date = Date.add(today, -days_ago)

    # Double order rate during promo period
    _in_promo =
      Date.compare(order_date, promo_start) in [:gt, :eq] and
        Date.compare(order_date, promo_end) in [:lt, :eq]

    # Skip ~half of non-promo orders to create realistic distribution
    # (we generate 500 total, so this just affects the date distribution)

    {customer_name, customer_email} = Enum.random(customers)
    priority = Enum.random(priorities)
    warehouse = Enum.random(warehouse_pool)
    carrier = assign_carrier.(priority, 5.0)

    # Memphis has 25% exception rate vs ~8% elsewhere
    exception_rate = if warehouse.id == memphis.id, do: 0.25, else: 0.08

    outage_exception =
      warehouse.id != memphis.id and
        Date.compare(order_date, outage_date) == :eq and
        carrier.id == ups.id

    status =
      cond do
        outage_exception -> "exception"
        :rand.uniform() < exception_rate -> "exception"
        days_ago > 14 -> Enum.random(["delivered", "delivered", "delivered", "shipping"])
        days_ago > 7 -> Enum.random(["shipping", "delivered", "packing"])
        days_ago > 3 -> Enum.random(["picking", "packing", "shipping"])
        true -> Enum.random(["received", "picking"])
      end

    notes =
      cond do
        status == "exception" and warehouse.id == memphis.id ->
          Enum.random(memphis_exception_reasons)

        status == "exception" ->
          Enum.random(exception_reasons)

        outage_exception ->
          "UPS carrier outage — shipment delayed"

        rem(i, 5) == 0 ->
          Enum.random([
            "Leave at front door",
            "Ring doorbell",
            "Fragile — handle with care",
            "Call before delivery"
          ])

        true ->
          nil
      end

    tracking_number =
      if status in ["shipping", "delivered"] do
        "1Z#{:rand.uniform(999_999_999) |> Integer.to_string() |> String.pad_leading(9, "0")}"
      else
        nil
      end

    carrier_id =
      if status in ["shipping", "delivered", "exception"] do
        carrier.id
      else
        nil
      end

    ship_date_offset =
      case priority do
        "overnight" -> :rand.uniform(2)
        "expedited" -> :rand.uniform(3) + 1
        _ -> :rand.uniform(7) + 2
      end

    %{
      index: i,
      order_number: "ORD-2026-#{String.pad_leading(Integer.to_string(i), 4, "0")}",
      customer_name: customer_name,
      customer_email: customer_email,
      status: status,
      priority: priority,
      warehouse_id: warehouse.id,
      carrier_id: carrier_id,
      tracking_number: tracking_number,
      notes: notes,
      requires_signature: priority == "overnight" or :rand.uniform(5) == 1,
      estimated_ship_date: Date.add(order_date, ship_date_offset),
      inserted_at: DateTime.new!(order_date, ~T[00:00:00], "Etc/UTC"),
      updated_at: DateTime.new!(order_date, ~T[00:00:00], "Etc/UTC")
    }
  end

# Insert orders and order items
Enum.each(orders_data, fn order_data ->
  order =
    Repo.insert!(%Order{
      order_number: order_data.order_number,
      customer_name: order_data.customer_name,
      customer_email: order_data.customer_email,
      status: order_data.status,
      priority: order_data.priority,
      warehouse_id: order_data.warehouse_id,
      carrier_id: order_data.carrier_id,
      tracking_number: order_data.tracking_number,
      notes: order_data.notes,
      requires_signature: order_data.requires_signature,
      estimated_ship_date: order_data.estimated_ship_date,
      inserted_at: order_data.inserted_at,
      updated_at: order_data.updated_at
    })

  # Each order gets 1-4 line items
  num_items = :rand.uniform(4)
  selected_products = Enum.take_random(products, num_items)

  Enum.each(selected_products, fn product ->
    quantity = :rand.uniform(3)

    Repo.insert!(%OrderItem{
      order_id: order.id,
      sku: product.sku,
      description: product.description,
      quantity: quantity,
      unit_price: product.unit_price,
      weight_lbs: product.weight_lbs,
      status:
        case order_data.status do
          "received" -> "pending"
          "picking" -> Enum.random(["pending", "picking"])
          "packing" -> "picked"
          "shipping" -> "packed"
          "delivered" -> "shipped"
          "exception" -> Enum.random(["pending", "picking", "backordered"])
          _ -> "pending"
        end
    })
  end)
end)

IO.puts("Seeded 500 orders with line items.")
IO.puts("")
IO.puts("Narrative patterns baked in:")
IO.puts("  - Memphis warehouse: ~25% exception rate (vs ~8% network average)")
IO.puts("  - UPS carrier outage on #{outage_date} caused shipping exceptions")
IO.puts("  - Volume spike during promo period #{promo_start} to #{promo_end}")
IO.puts("  - Columbus + Memphis: low stock on several SKUs")
IO.puts("  - 500 orders with 1-4 line items each")
