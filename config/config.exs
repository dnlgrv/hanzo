use Mix.Config

# config :hanzo, Hanzo.Slack,
#   token: "BOT TOKEN"
#
# config :parse_client,
#   parse_application_id: "PARSE APPLICATION ID",
#   parse_api_key: "PARSE API KEY"

config :logger, :console,
  format: "$time [$level] $message\n\n"

import_config "secret.exs"
