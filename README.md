# Fulfillment Pipeline

A production-grade order fulfillment pipeline built with Elixir, Phoenix, and OTP. 
Demonstrates real-time order processing using GenServer, DynamicSupervisor, Phoenix 
PubSub, and LiveView.

Built as a portfolio project targeting supply chain / fulfillment software engineering 
roles. The domain maps directly to OMS/WMS systems used in DTC brand fulfillment.

---

## Architecture

### Why GenServer per order?
Each active order runs as its own supervised OTP process. This mirrors how a real 
fulfillment system works — orders are independent units of work that move through 
a pipeline concurrently. A problem with one order should never affect another.

Alternatives considered:
- Single GenServer managing all orders: creates a bottleneck and a single point of 
  failure
- Pure database polling: no real-time behavior, adds latency

### Why DynamicSupervisor?
Order volume is unknown at compile time. DynamicSupervisor starts and monitors child 
processes at runtime as orders are created, rather than requiring a fixed child list 
at startup.

### Why a Registry?
GenServer processes are identified by PID, which changes on restart. The Registry maps 
a stable key (order ID) to the current PID. Callers never deal with PIDs directly — 
they look up an order by ID and the Registry resolves the current process transparently.

### The Hydrator
On application boot, the Hydrator queries all non-delivered orders and starts a 
GenServer for each one. Without this, only orders created during the current server 
session would have live processes. Delivered orders are excluded — they are terminal 
and need no in-memory representation.

### Why LiveView instead of React?
LiveView handles real-time UI updates over a persistent websocket connection without 
writing JavaScript. PubSub broadcasts order state changes to all connected LiveView 
clients simultaneously. For internal operational tooling — which is what a fulfillment 
dashboard is — this is the correct architectural choice.

### PubSub pattern
GenServer processes do not talk to LiveView directly. Instead they broadcast events 
to a named PubSub topic ("orders"). Any LiveView subscribed to that topic receives 
the event and re-renders. This keeps the pipeline layer decoupled from the UI layer.

### "Let it crash"
OTP's fault tolerance model: processes are not defensive. If an order process 
encounters an unexpected state, it crashes. The DynamicSupervisor detects the crash 
and restarts the process automatically, reloading order state from the database. 
This is verified in the test suite via `Process.exit(pid, :kill)`.

### Process restoration query pattern
On boot, the process restorer fetches all active orders in a single query, 
then starts a GenServer per order. Each GenServer loads its own state 
independently via individual queries. This is intentional — each process 
owns its state, and the individual query pattern also supports crash recovery 
where the Supervisor restarts a process with only an order ID.


---

## Order Data Model

### order_number
Free-form string. No enforced format at the database level, but the convention used 
in seeds and production intent is `ORD-YYYY-NNNN` (e.g. `ORD-2026-0042`). Enforced 
unique at the database level via a unique index.

In production this would be auto-generated on order creation rather than supplied 
by the user.

### status (state machine)
Valid values and intended transitions:
received → picking → packing → shipping → delivered
Any stage → exception

Status is validated on write via `validate_inclusion`. Transition enforcement 
(e.g. preventing delivered → picking) is handled by the GenServer layer, not the 
database layer. The database accepts any valid status value to support administrative 
corrections.

### priority
Valid values: `standard`, `expedited`, `overnight`. Validated on write.
In production this would drive SLA timers and carrier selection.

### customer_email
Validated against `~r/^[^\s]+@[^\s]+\.[^\s]+$/` — basic format check confirming 
no whitespace, an @ symbol, and a domain with a TLD. 

In production this would be supplemented with MX record verification or delegated 
to the transactional email provider (e.g. SendGrid, Postmark) at send time.

### warehouse_id
Currently a plain integer referencing one of three seeded warehouse locations:
- 1 = Sacramento, CA
- 2 = Dallas, TX  
- 3 = Columbus, OH

A full `warehouses` table with its own CRUD is planned. The foreign key relationship 
will be enforced at the database level once that table exists.

### items
Stored as `jsonb` (Elixir `:map` type). Currently holds a single SKU, description, 
and quantity. In production this would be an array of line items or a normalized 
`order_items` table.

### requires_signature
Boolean. Defaults to false. Drives delivery instructions — in production this would 
be passed to the carrier API at shipping time.

### estimated_ship_date
Date (not datetime). Represents the target ship date, not a guarantee. In production 
this would be calculated from priority + warehouse SLA rules.

### order_items
Normalized line items replacing the previous `items` jsonb field on orders. Each order 
can have multiple line items with their own SKU, description, quantity, unit price, 
weight, and status.

Item statuses are more granular than order statuses:
`pending → picking → picked → packed → shipped`
with `backordered` and `exception` as exception states.

**Design decision:** SKUs are denormalized as strings into order_items rather than 
referencing a separate products table. A normalized products/SKU catalog is planned 
for Sprint 3.

**on_delete: :delete_all** — deleting an order cascades to delete its line items.

### carriers
Reference table for shipping carriers. Orders reference a carrier once they 
reach `shipping` status.

Fields: `name`, `code` (unique, 2-10 chars), `active`, `max_weight_lbs`, 
`tracking_url_template`.

**on_delete: :nilify_all** on orders — deleting a carrier nullifies the 
carrier reference on orders rather than deleting the orders themselves.

Planned carriers: UPS, FedEx, USPS, OnTrac, FreightCo.

### tracking_number
String field on orders, populated when status reaches `shipping`. No 
uniqueness constraint — different carriers can reuse tracking numbers.

### inventory_items
Tracks stock levels per SKU per warehouse. Each SKU can exist in multiple 
warehouses but only once per warehouse (unique constraint on 
`[:warehouse_id, :sku]`).

Fields:
- `sku` — product identifier, matches SKU on order_items
- `description` — product name
- `quantity_on_hand` — physical stock count in the warehouse
- `quantity_reserved` — allocated to open orders, not yet picked
- `reorder_point` — alert threshold; when on_hand drops to or below this 
  level the item appears in low stock reports
- `unit_cost` — cost per unit (not sale price)

**quantity_available** is a virtual field computed as 
`quantity_on_hand - quantity_reserved`. Not persisted.

**on_delete: :restrict** on warehouses — a warehouse with inventory cannot 
be deleted until inventory is cleared.

### Key inventory context functions
- `list_inventory_items_for_warehouse/1` — returns all SKUs for a specific 
  warehouse, ordered by SKU
- `get_inventory_item_by_sku/2` — looks up a specific SKU at a specific 
  warehouse
- `low_stock_items/0` — returns all items across all warehouses where 
  quantity_on_hand is at or below reorder_point. Primary data source for 
  Claude exception analysis.

---

## Setup

### Prerequisites
- Elixir 1.14+
- Phoenix 1.7+
- PostgreSQL running on port 5432

### Install dependencies
```bash
mix deps.get
```

### Configure database
Edit `config/dev.exs` and set your Postgres credentials:
```elixir
username: "postgres",
password: "postgres",
hostname: "localhost"
```

### Create and migrate database
```bash
mix ecto.create
mix ecto.migrate
```

### Seed with sample data
75 realistic orders across 25 customers and 3 warehouse locations:
```bash
mix run priv/repo/seeds.exs
```

Re-running seeds clears existing orders first. Safe to run multiple times.

### Start the server
```bash
iex -S mix phx.server
```

Visit `http://localhost:4000/pipeline` for the live dashboard.  
Visit `http://localhost:4000/orders` for order management.

---

## Running Tests
```bash
mix test
```

Test suite covers:
- Context CRUD operations
- Changeset validations (email format, status inclusion, priority inclusion, 
  unique order number)
- GenServer lifecycle (startup, pipeline advancement, exception triggering)
- Supervisor crash recovery — kills a process with `Process.exit/2` and asserts 
  the supervisor restarts it with a new PID and correct state

---

## Known Limitations / Production TODOs
- `order_number` is user-supplied; should be auto-generated
- `warehouse_id` is a plain integer; a `warehouses` table is planned
- `items` is a single jsonb object; production would use normalized `order_items`
- Email validation is format-only; MX verification not implemented
- No authentication — all routes are public
- No pagination on order list
- Status transitions are not enforced at the database level
- Claude API exception analysis is planned but not yet implemented