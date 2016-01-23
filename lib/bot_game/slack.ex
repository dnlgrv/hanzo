defmodule BotGame.Slack do
  use Slack

  @token Application.get_env(:bot_game, __MODULE__)[:token]

  def start_link do
    start_link(@token, [])
  end

  def handle_connect(slack, state) do
    IO.puts "Connected as #{slack.me.name}"
    {:ok, state}
  end
end
