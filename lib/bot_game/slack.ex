defmodule BotGame.Slack do
  use Slack

  @token Application.get_env(:bot_game, __MODULE__)[:token]

  def start_link do
    start_link(@token, [])
  end

  def handle_connect(slack, state) do
    {:ok, %{id: slack.me.id, started_games: []}}
  end

  def handle_message(message, slack, state = %{id: id, started_games: games}) do
    games = handle_incoming_message(message, slack, id, games)
    {:ok, %{id: id, started_games: games}}
  end

  def handle_incoming_message(message = %{type: "message",
                                          text: "start",
                                          channel: <<"D", _rest::binary>>},
                              slack, id, games) do
    if Enum.member?(games, message.user) do
      Slack.send_message("Finish the game you've started first. If you've had enough, type 'stop' to finish playing.", message.channel, slack)
    else
      {:ok, _game} = BotGame.Game.Supervisor.start_game(slack, message.channel, message.user)
      games = [message.user | games]
    end

    games
  end

  def handle_incoming_message(message = %{type: "message",
                                          text: "stop",
                                          channel: <<"D", _rest::binary>>},
                              slack, id, games) do
    if Enum.member?(games, message.user) do
      BotGame.Game.stop(message.user)
      games = Enum.filter(games, &(&1 != message.user))
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
  def handle_incoming_message(message, slack, id, games), do: games
end
