use Mix.Config

username = System.get_env("DB_USER")
password = System.get_env("DB_PASSWORD")
database = System.get_env("DB_NAME")
hostname = System.get_env("DB_HOST")

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :petree_api, PetreeApi.Repo,
  username: username,
  password: password,
  database: String.replace(database, "?", "test"),
  hostname: hostname,
  port: 5432,
  pool: Ecto.Adapters.SQL.Sandbox,
  types: PetreeApi.PostgresTypes

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :petree_api, PetreeApiWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

config :bcrypt_elixir, :log_rounds, 4
