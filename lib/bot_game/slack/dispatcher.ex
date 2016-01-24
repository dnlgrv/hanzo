defmodule BotGame.Slack.Dispatcher do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def register(ref) do
    GenServer.call(__MODULE__, {:register, ref})
  end

  def dispatch(message, slack) do
    GenServer.cast(__MODULE__, {:dispatch, message, slack})
  end

  def handle_call({:register, ref}, _from, refs) do
    {:reply, :ok, [ref | refs]}
  end

  def handle_cast({:dispatch, message, slack}, refs) do
    Enum.each(refs, fn (ref) ->
      send(ref, {:message, message, slack})
    end)

    {:noreply, refs}
  end
end
