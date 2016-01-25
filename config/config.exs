use Mix.Config

# config :bot_game, BotGame.Slack.Client,
#   token: "BOT TOKEN"

config :logger, :console,
  format: "$time [$level] $message\n\n"

import_config "secret.exs"
