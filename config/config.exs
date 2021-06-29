import Config

config :tesla, adapter: Tesla.Adapter.Hackney
config :logger, :console, format: "[$level] $message\n"

import_config "secret.exs"
