# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :petree_api,
  ecto_repos: [PetreeApi.Repo],
  generators: [binary_id: true]

# Configures the endpoint
config :petree_api, PetreeApiWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "MJJbGB00+mBAUOLzEztejvlRH5riMKdXYeDVCPA2VM34rcdXe3NQC0IRvClEqQaY",
  render_errors: [view: PetreeApiWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: PetreeApi.PubSub,
  live_view: [signing_salt: "DfRRCePj"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Use Jason for JSON parsing in geo_postgis
config :geo_postgis, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
