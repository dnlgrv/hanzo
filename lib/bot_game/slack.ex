defmodule BotGame.Slack do
  use Slack

  @token Application.get_env(:bot_game, __MODULE__)[:token]

  def start_link do
    start_link(@token, [])
  end

  def handle_connect(slack, _state) do
    {:ok, %{id: slack.me.id, started_games: %{}}}
  end

  def handle_message(message, slack, %{id: id, started_games: games}) do
    games = handle_incoming_message(message, slack, id, games)
    {:ok, %{id: id, started_games: games}}
  end

  def handle_incoming_message(message = %{type: "message",
                                          text: "start",
                                          channel: <<"D", _rest::binary>>},
                              slack, _id, games) do
    if Map.has_key?(games, message.user) do
      Slack.send_message("Finish the game you've started first. If you've had enough, type 'stop' to finish playing.", message.channel, slack)
    else
      {:ok, game_pid} = BotGame.Game.Supervisor.start_game(message.channel, slack, message.user)
      ref = Process.monitor(game_pid)
      games = Map.put(games, message.user, ref)
    end

    games
  end

  def handle_incoming_message(message = %{type: "message",
                                          text: "stop",
                                          channel: <<"D", _rest::binary>>},
                              _slack, _id, games) do
    if Map.has_key?(games, message.user) do
      BotGame.Game.stop(message.user)
    end

    games
  end

  def handle_incoming_message(message = %{type: "message",
                                          text: "help",
                                          channel: <<"D", _rest::binary>>},
                              slack, id, games) do
    Slack.send_message("Type 'start' to start playing.", message.channel, slack)
    games
  end

  def handle_incoming_message(message = %{type: "message",
                                          text: text,
                                          channel: <<"D", _rest::binary>>},
                              slack, id, games) do
    if Map.has_key?(games, message.user) do
      BotGame.Game.handle_message(message)
    end

    games
  end

  def handle_incoming_message(message, slack, id, games), do: games

  def handle_info({:DOWN, game_ref, :process, _pid, _info}, _slack, state = %{started_games: games}) do
    {key, _val} = Enum.find(games, fn ({user, ref}) ->
      ref == game_ref
    end)
    games = Map.delete(games, key)
    state = Map.put(state, :started_games, games)
    {:ok, state}
  end
end
