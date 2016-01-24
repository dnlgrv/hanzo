defmodule BotGame.Slack.Client do
  use Slack

  @token Application.get_env(:bot_game, __MODULE__)[:token]

  def start_link(mod) do
    start_link(@token, GenServer.whereis(mod))
  end

  def handle_connect(slack, parent) do
    send(parent, {:handle_connect, slack})
    {:ok, parent}
  end

  def handle_info({:parent_ref, parent}, _slack, _parent) do
    {:ok, parent}
  end

  def handle_message(message, slack, parent) do
    send(parent, {:handle_message, message, slack})
    {:ok, parent}
  end
end
