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
