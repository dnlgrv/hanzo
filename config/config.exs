use Mix.Config

# config :hanzo, Hanzo.Slack,
#   token: "BOT TOKEN"

config :logger, :console,
  format: "$time [$level] $message\n\n"

import_config "secret.exs"
