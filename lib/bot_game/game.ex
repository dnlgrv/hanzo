defmodule BotGame.Game do
  use GenServer

  def start_link(channel) do
    GenServer.start_link(__MODULE__, channel, name: via_tuple(channel))
  end

  def stop(channel) do
    GenServer.stop(via_tuple(channel))
  end

  def init(channel) do
    BotGame.Slack.send_message("Game started", channel)
    {:ok, channel}
  end

  defp via_tuple(channel) do
    {:via, BotGame.Registry, {:game, channel}}
  end
end
