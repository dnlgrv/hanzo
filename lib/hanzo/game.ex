defmodule Hanzo.Game do
  use GenFSM

  alias Hanzo.Game.Data
  import Hanzo.Slack, only: [send_message: 2]

  def start_link(channel) do
    GenFSM.start_link(__MODULE__, Data.new(channel), name: via_tuple(channel))
  end

  def init(data) do
    {:ok, data.state, data, 0}
  end

  def new_player(user, channel) do
    case Hanzo.Registry.whereis_name(ref(channel)) do
      :undefined -> :ok # Game isn't running
      pid -> :gen_fsm.send_event(pid, {:new_player, user})
    end
  end

  # States

  def start(:timeout, data) do
    send_message("Game started.\nIf you want to participate, just @ me saying 'play'.", data.channel)
    data = Data.put_state(data, :playing)
    {:next_state, data.state, data}
  end

  def playing({:new_player, id}, data) do
    case Hanzo.Game.Player.Supervisor.new_player(id, data.channel) do
      {:ok, _} ->
        send_message("<@#{id}> has joined the game!", data.channel)
        data = Data.put_player(data, id)
      _ -> :ok
    end

    {:next_state, data.state, data}
  end
  def playing(_msg, data) do
    {:next_state, data.state, data}
  end

  # Private

  defp ref(channel) do
    {:game, channel}
  end

  defp via_tuple(channel) do
    {:via, Hanzo.Registry, ref(channel)}
  end
end
