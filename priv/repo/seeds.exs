# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     FulfillmentPipeline.Repo.insert!(%FulfillmentPipeline.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias FulfillmentPipeline.Repo
alias FulfillmentPipeline.Fulfillment.Order

Repo.delete_all(Order)

:rand.seed(:exsss, {System.os_time(:millisecond), 0, 0})

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

statuses = ["received", "picking", "packing", "shipping", "delivered", "exception"]
priorities = ["standard", "standard", "standard", "expedited", "expedited", "overnight"]

products = [
  %{"sku" => "SKU-001", "description" => "Wireless Headphones", "quantity" => 1},
  %{"sku" => "SKU-002", "description" => "Laptop Stand", "quantity" => 1},
  %{"sku" => "SKU-003", "description" => "USB-C Hub", "quantity" => 2},
  %{"sku" => "SKU-004", "description" => "Mechanical Keyboard", "quantity" => 1},
  %{"sku" => "SKU-005", "description" => "Webcam HD", "quantity" => 1},
  %{"sku" => "SKU-006", "description" => "Monitor Arm", "quantity" => 2},
  %{"sku" => "SKU-007", "description" => "Desk Mat XL", "quantity" => 1},
  %{"sku" => "SKU-008", "description" => "LED Desk Lamp", "quantity" => 3},
  %{"sku" => "SKU-009", "description" => "Cable Management Kit", "quantity" => 1},
  %{"sku" => "SKU-010", "description" => "Ergonomic Mouse", "quantity" => 1},
  %{"sku" => "SKU-011", "description" => "Standing Desk Converter", "quantity" => 1},
  %{"sku" => "SKU-012", "description" => "Blue Light Glasses", "quantity" => 2},
  %{"sku" => "SKU-013", "description" => "Portable SSD 1TB", "quantity" => 1},
  %{"sku" => "SKU-014", "description" => "Noise Cancelling Earbuds", "quantity" => 1},
  %{"sku" => "SKU-015", "description" => "Smart Power Strip", "quantity" => 1}
]

exception_notes = [
  "Item damaged during picking — replacement needed",
  "Inventory count mismatch for SKU",
  "Customer address undeliverable",
  "Carrier refused pickup — weight limit exceeded",
  "Packing materials shortage — order on hold",
  "Duplicate order flagged for review"
]

notes_options = [
  "Leave at front door",
  "Ring doorbell, do not leave if no answer",
  "Fragile contents — handle with care",
  "Call customer before delivery",
  nil,
  nil,
  nil,
  nil
]

for i <- 1..75 do
  {name, email} = Enum.random(customers)
  status = Enum.random(statuses)
  priority = Enum.random(priorities)
  warehouse_id = :rand.uniform(3)
  days_ahead = :rand.uniform(21) - 7
  product = Enum.random(products)

  notes =
    if status == "exception" do
      Enum.random(exception_notes)
    else
      Enum.random(notes_options)
    end

  Repo.insert!(%Order{
    order_number: "ORD-2026-#{String.pad_leading(Integer.to_string(i), 4, "0")}",
    customer_name: name,
    customer_email: email,
    status: status,
    priority: priority,
    warehouse_id: warehouse_id,
    requires_signature: :rand.uniform(4) == 1,
    estimated_ship_date: Date.add(Date.utc_today(), days_ahead),
    notes: notes,
    items: product
  })
end

IO.puts("Seeded 75 orders across 3 warehouses and 25 customers.")
