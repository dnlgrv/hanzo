defmodule BotGame.Game do
  use GenServer
  import Slack, only: [send_message: 3]

  # When wanting to create multiple games we should specify a dynamic name here
  # instead. Using {:global, TERM} we can make the game accessible globally.
  def start_link(slack, channel, name) do
    initial_state = {slack, channel}
    {:ok, pid} = GenServer.start_link(__MODULE__, initial_state, name: _name(name))

    send(pid, :game_started)

    {:ok, pid}
  end

  def stop(name) do
    GenServer.stop({:global, {:game, name}})
  end


  def handle_info(:game_started, state = {slack, channel}) do
    send_message("Game started.", channel, slack)
    {:noreply, state}
  end

  def terminate(_reason, {slack, channel}) do
    send_message("Game stopped.", channel, slack)
    :ok
  end

  defp _name(name), do: {:global, {:game, name}}
end
