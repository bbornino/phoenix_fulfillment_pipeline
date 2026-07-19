# Fulfillment Pipeline

A production-grade order fulfillment pipeline built with Elixir, Phoenix, and OTP.
Demonstrates real-time order processing using GenServer, DynamicSupervisor, Phoenix
PubSub, LiveView, and Claude AI exception analysis.

Built as a portfolio project targeting supply chain / fulfillment software engineering
roles. The domain maps directly to OMS/WMS systems used in DTC brand fulfillment.

- **Portfolio:** https://bornino.net/projects/phoenix-fulfillment-pipeline/
- **GitHub:** https://github.com/bbornino/phoenix_fulfillment_pipeline

---

## Architecture

### Why GenServer per order?
Each active order runs as its own supervised OTP process. This mirrors how a real
fulfillment system works — orders are independent units of work that move through
a pipeline concurrently. A problem with one order should never affect another.

Alternatives considered:
- Single GenServer managing all orders: creates a bottleneck and a single point of failure
- Pure database polling: no real-time behavior, adds latency

### Why DynamicSupervisor?
Order volume is unknown at compile time. DynamicSupervisor starts and monitors child
processes at runtime as orders are created, rather than requiring a fixed child list
at startup.

### Why a Registry?
GenServer processes are identified by PID, which changes on restart. The Registry maps
a stable key (order ID) to the current PID. Callers never deal with PIDs directly —
they look up an order by ID and the Registry resolves the current process transparently.

### Process Restoration (Hydrator)
On application boot, the process restorer queries all non-delivered orders and starts
a GenServer for each one. Without this, only orders created during the current server
session would have live processes. Delivered orders are excluded — they are terminal
and need no in-memory representation.

The term "Hydrator" is project-specific, not standard OTP terminology. The pattern
itself — restoring in-memory process state from a persistent store on boot — is
standard OTP practice, sometimes called a "warm start."

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

### Claude AI Exception Analysis
When an order enters exception state, an `ExceptionAnalyzer` module runs as a
supervised Task. It builds a rich prompt from order details, line items, and
inventory context, then calls the Claude API. Results are saved to the database
and broadcast via PubSub to update the LiveView dashboard in real time.

The Task runs independently of the websocket connection — if the browser times out
during a long API call, the analysis still completes and updates when reconnected.

---

## Data Model

### orders
Core entity. Tracks an order from placement through fulfillment.

Key fields:
- `order_number` — unique string, convention `ORD-YYYY-NNNN`. In production would be auto-generated.
- `status` — state machine: `received → picking → packing → shipping → delivered`, any stage `→ exception`
- `priority` — `standard`, `expedited`, `overnight`. Drives SLA and carrier selection.
- `customer_email` — validated against `~r/^[^\s]+@[^\s]+\.[^\s]+$/`. In production: MX verification or transactional email provider validation.
- `carrier_id` — FK to carriers, set when order reaches `shipping` status
- `tracking_number` — populated at shipping. No uniqueness constraint — carriers reuse numbers.
- `exception_analysis` — text field populated by Claude AI when an order hits exception state
- `exception_raised_at` — timestamp set when exception is triggered, used to calculate exception duration for Claude analysis

Status transition enforcement is handled at the GenServer layer, not the database layer.
The database accepts any valid status to support administrative corrections.

### order_items
Normalized line items. Each order has 1-4 line items with their own SKU, quantity, price, weight, and status.

Item statuses are more granular than order statuses: `pending → picking → picked → packed → shipped`, with `backordered` and `exception` as exception states.

**Design decision:** SKUs are denormalized as strings rather than referencing a separate products table. A normalized products/SKU catalog is a future sprint item.

**on_delete: :delete_all** — deleting an order cascades to delete its line items.

### warehouses
Six fulfillment centers across the US. Full CRUD via the Warehouses UI.

Fields: `name`, `city`, `state`, `zip`, `capacity`, `active`, `manager_name`, `manager_email`.

### carriers
Reference table for shipping carriers. Seeded with UPS, FedEx, USPS, OnTrac, and FreightCo LTL.

Fields: `name`, `code` (unique, 2-10 chars), `active`, `max_weight_lbs`, `tracking_url_template`.

**on_delete: :nilify_all** on orders — deleting a carrier nullifies the carrier reference on orders rather than deleting the orders themselves.

### inventory_items
Stock levels per SKU per warehouse. Unique constraint on `[:warehouse_id, :sku]`.

Fields: `sku`, `description`, `quantity_on_hand`, `quantity_reserved`, `reorder_point`, `unit_cost`.

`quantity_available` is a virtual field (`on_hand - reserved`). Not persisted.

**on_delete: :restrict** — a warehouse with inventory cannot be deleted until inventory is cleared.

Key context functions:
- `list_inventory_items_for_warehouse/1` — all SKUs for a warehouse, ordered by SKU
- `get_inventory_item_by_sku/2` — specific SKU at a specific warehouse
- `low_stock_items/0` — items where `quantity_on_hand <= reorder_point` across all warehouses. Primary data source for Claude exception analysis.

---

## Seed Data
500 orders across 6 warehouses, 25 customers, and 5 carriers with narrative patterns
baked in for meaningful Claude analysis:

- **Memphis warehouse:** ~25% exception rate vs ~8% network average — signals staffing or process issues
- **UPS carrier outage:** Cluster of shipping exceptions on a specific date
- **Promo volume spike:** 2x order rate during a 7-day period ~6 weeks ago
- **Low stock:** Columbus and Memphis warehouses have several SKUs at or below reorder point
- **Order items:** Each order has 1-4 line items with realistic SKUs, quantities, and weights

Re-running seeds clears all existing data first. Safe to run multiple times.

---

## Setup

### Prerequisites
- Elixir 1.14+
- Phoenix 1.7+
- PostgreSQL running on port 5432
- Anthropic API key (get one at https://console.anthropic.com)

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

### Environment Variables
Create a `run_server.bat` file in the project root (already in `.gitignore`):
```bat
set ANTHROPIC_API_KEY=your_anthropic_api_key_here
iex.bat -S mix phx.server
```

### Seed with sample data
```bash
mix run priv/repo/seeds.exs
```

### Start the server
```bat
run_server.bat
```

**Key URLs:**
- `http://localhost:4000/pipeline` — live fulfillment dashboard
- `http://localhost:4000/orders` — order management (CRUD)
- `http://localhost:4000/warehouses` — warehouse management (CRUD)
- `http://localhost:4000/operations` — carriers, low stock alerts, inventory by warehouse

---

## Running Tests
```bash
mix test
```

Test suite covers:
- Context CRUD operations for orders, warehouses, carriers, inventory, and order items
- Changeset validations (email format, status inclusion, priority inclusion, unique constraints)
- GenServer lifecycle — startup, pipeline advancement, exception triggering, terminal state
- Supervisor crash recovery — kills a process with `Process.exit/2` and asserts the supervisor restarts it with a new PID and correct state
- LiveView dashboard — renders orders, advance and exception buttons update state in real time

---

## Known Limitations / Production TODOs
- `order_number` is user-supplied; should be auto-generated on order creation
- No authentication — all routes are public
- Status transitions not enforced at the database level (GenServer layer only)
- Email validation is format-only; MX verification not implemented
- SKUs are denormalized strings; a normalized products/catalog table is planned
- No pagination on the pipeline dashboard (orders list has pagination)
- Claude exception analysis runs synchronously in a Task; a queue-based approach would be more robust at scale
- `quantity_available` is a virtual field not persisted to the database


