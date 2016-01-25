defmodule BotGame.Slack.Client do
  @module ~S"""
  A simple wrapper around the `Slack` library.

  Takes a module as an argument that responds to `connect/1` and
  `incoming_message/2`. In our case this is the `BotGame.Slack` module.

  All calls from this module should be delegated to the parent module, as this
  library is prone to not so useful error messages.
  """

  use Slack

  @token Application.get_env(:bot_game, BotGame.Slack)[:token]

  def start_link(mod) do
    start_link(@token, mod)
  end


  def handle_connect(_slack, parent) do
    parent.connect(self)
    {:ok, parent}
  end

  def handle_message(message, slack, parent) do
    parent.incoming_message(message, slack)
    {:ok, parent}
  end

  def handle_info({:send_message, message, channel}, slack, parent) do
    Slack.send_message(message, channel, slack)
    {:ok, parent}
  end
end
