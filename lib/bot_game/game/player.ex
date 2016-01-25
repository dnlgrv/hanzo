defmodule BotGame.Game.Player do
  use GenServer

  def start_link(channel, id) do
    GenServer.start_link(__MODULE__, {channel, id}, name: via_tuple(id))
  end

  def init(state = {channel, id}) do
    BotGame.Slack.send_message("<@#{id}> has joined the game!", channel)
    {:ok, state}
  end

  defp via_tuple(id) do
    {:via, BotGame.Registry, {:player, id}}
  end
end
