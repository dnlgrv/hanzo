defmodule BotGame.Slack do
  use GenServer

  @supervisor BotGame.Slack.Supervisor

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    send(self(), :send_ref_to_client)
    {:ok, []}
  end

  def handle_info(:send_ref_to_client, state) do
    @supervisor
    |> GenServer.whereis()
    |> Supervisor.which_children()
    |> Enum.each(fn
      {BotGame.Slack.Client, pid, _, _} ->
        send(pid, {:parent_ref, self()})
      _ ->
        :ok
    end)

    {:noreply, state}
  end

  def handle_info({:handle_connect, slack}, state) do
    {:noreply, %{id: slack.me.id}}
  end

  def handle_info({:handle_message, message = %{type: "message"}, slack}, state) do
    BotGame.Slack.Dispatcher.dispatch(message, slack)
    {:noreply, state}
  end

  def handle_info(_msg, state), do: {:noreply, state}
end
