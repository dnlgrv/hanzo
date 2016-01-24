defmodule BotGame.Game do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, [], name: {:global, {:game, __MODULE__}})
  end

  def handle_info({:message, message, slack}, state) do
    {:noreply, state}
  end
end
