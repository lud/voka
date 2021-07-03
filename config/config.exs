# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

# Configures the endpoint
config :voka, VokaWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "04c9AdOSj1aqMX/fwyQR3Qqve3s44mVxON1S6pu6CJYI8EaTi77AurLno8Tp0fQL",
  render_errors: [view: VokaWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: Voka.PubSub,
  live_view: [signing_salt: "v7aY9int"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"


config :tesla, adapter: Tesla.Adapter.Hackney
config :logger, :console, format: "[$level] $message\n"

import_config "secret.exs"
