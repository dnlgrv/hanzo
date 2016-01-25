defmodule BotGame.Game do
  use GenServer

  def start_link(channel) do
    GenServer.start_link(__MODULE__, channel, name: via_tuple(channel))
  end

  def stop(channel) do
    GenServer.stop(via_tuple(channel))
  end

  def init(channel) do
    BotGame.Slack.send_message("Game started.\nIf you want to participate, just @ me saying 'play'.", channel)
    {:ok, %{channel: channel, players: []}}
  end

  def new_player(id, channel) do
    GenServer.cast(via_tuple(channel), {:new_player, id})
  end

  def handle_cast({:new_player, id}, state = %{channel: channel, players: players}) do
    BotGame.Slack.send_message("<@#{id}> has joined the game!", channel)
    BotGame.Game.Player.Supervisor.new_player(id, channel)
    players = [id | players]
    {:noreply, Map.put(state, :players, players)}
  end

  defp via_tuple(channel) do
    {:via, BotGame.Registry, {:game, channel}}
  end
end
