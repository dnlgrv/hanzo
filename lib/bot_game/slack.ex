defmodule BotGame.Slack do
  use Slack

  @token Application.get_env(:bot_game, __MODULE__)[:token]

  def start_link do
    start_link(@token, [])
  end

  def handle_connect(slack, state) do
    {:ok, game} = BotGame.Game.Supervisor.start_game(slack)
    {:ok, %{id: slack.me.id, game: game}}
  end

  def handle_message(message, slack, %{id: id, game: game}) do
    {id, game} = handle_incoming_message(message, slack, id, game)
    {:ok, %{id: id, game: game}}
  end


  def handle_incoming_message(message = %{type: "message",
                                          channel: <<"D", _rest::binary>>,
                                          text: "help"}, slack, id, game) do
    BotGame.Game.send_instructions(message.channel)
    {id, game}
  end
  def handle_incoming_message(message, slack, id, game), do: {id, game}
end
