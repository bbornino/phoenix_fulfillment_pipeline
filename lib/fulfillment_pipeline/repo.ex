defmodule FulfillmentPipeline.Repo do
  use Ecto.Repo,
    otp_app: :fulfillment_pipeline,
    adapter: Ecto.Adapters.Postgres
end
