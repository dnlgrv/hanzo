# Hanzo

Slack bot for games.

## Setup

* `mix deps.get`
* `mix run --no-halt` or `iex -S mix`

## Configuration

Create a secret config file: `config/secret.exs`. Provide configuration for
Slack and Parse.

```elixir
use Mix.Config

config :hanzo, Hanzo.Slack,
  token: "BOT TOKEN"

config :parse_client,
  parse_application_id: "PARSE APPLICATION ID",
  parse_api_key: "PARSE API KEY"
```

## Game over

To "finish" a game, you need to tell Hanzo to calculate the scores. You'll need
to provide the Slack Channel ID (can be found in Parse under a particular
player):

```elixir
iex -S mix
Hanzo.Game.calculate_scores("CHANNELID")
```
