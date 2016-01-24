defmodule BotGame.Slack do
  use GenServer
  alias BotGame.Slack.Client

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
    {:noreply, %{id: slack.me.id, games: %{}}}
  end

  def handle_info({:handle_message, message = %{type: "message",
      text: "help",
      channel: <<"D", _rest::binary>>}, slack}, state) do
    Slack.send_message("Type 'start' to start playing.", message.channel, slack)
    {:noreply, state}
  end

  def handle_info({:handle_message, message = %{type: "message",
      text: "start",
      channel: <<"D", _rest::binary>>}, slack}, state) do
    games = Map.get(state, :games)

    if Map.has_key?(games, message.user) do
      Slack.send_message("Finish the game you've started first. If you've had enough, type 'stop' to finish playing.", message.channel, slack)
    else
      {:ok, game_pid} = BotGame.Game.Supervisor.start_game(message.channel, slack, message.user)
      ref = Process.monitor(game_pid)
      games = Map.put(games, message.user, ref)
    end

    {:noreply, Map.put(state, :games, games)}
  end

  def handle_info({:handle_message, message = %{type: "message",
      text: "stop",
      channel: <<"D", _rest::binary>>}, _slack}, state) do
    games = Map.get(state, :games)

    if Map.has_key?(games, message.user) do
      BotGame.Game.stop(message.user)
    end

    {:noreply, state}
  end

  def handle_info({:handle_message, message = %{type: "message",
      text: text,
      channel: <<"D", _rest::binary>>}, _slack}, state) do
    games = Map.get(state, :games)

    if Map.has_key?(games, message.user) do
      BotGame.Game.handle_message(message)
    end

    {:noreply, Map.put(state, :games, games)}
  end

  def handle_info({:DOWN, game_ref, :process, _pid, _info}, state = %{games: games}) do
    {key, _val} = Enum.find(games, fn ({user, ref}) ->
      ref == game_ref
    end)
    games = Map.delete(games, key)
    {:noreply, Map.put(state, :games, games)}
  end

  def handle_info(_msg, state), do: {:noreply, state}
end
