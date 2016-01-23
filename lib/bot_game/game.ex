defmodule BotGame.Game do
  use GenServer

  # When wanting to create multiple games we should specify a dynamic name here
  # instead. Using {:global, TERM} we can make the game accessible globally.
  def start_link(slack) do
    GenServer.start_link(__MODULE__, slack, name: __MODULE__)
  end

  def send_instructions(channel) do
    GenServer.cast(__MODULE__, {:help, channel})
  end

  def handle_info({:message, text}, slack) do
    {:noreply, slack}
  end

  def handle_cast({:help, channel}, slack) do
    Slack.send_message("I can't help you, sorry", channel, slack)
    {:noreply, slack}
  end
end
