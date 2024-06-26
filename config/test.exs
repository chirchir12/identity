import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :identity, Identity.Repo,
  username: System.get_env("IDENTITY_DB_TEST_USER", "postgres"),
  password: System.get_env("IDENTITY_DB_TEST_PASS", "postgres"),
  hostname: System.get_env("DB_TEST_HOST", "localhost"),
  database: "identity_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :identity, IdentityWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "7yjtZF7ZztaUSbDc2YcNaodEaazKRdibDKzcjasCv4gFRuRds0awnrhkC3/2xv5S",
  server: false

# In test we don't send emails.
config :identity, Identity.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

config :phoenix_live_view,
  # Enable helpful, but potentially expensive runtime checks
  enable_expensive_runtime_checks: true

# to speed up tests
config :argon2_elixir,
  t_cost: 1,
  m_cost: 8
