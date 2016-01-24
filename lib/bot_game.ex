defmodule BotGame do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      supervisor(BotGame.Slack.Supervisor, []),
      supervisor(BotGame.Game.Supervisor, []),
      worker(BotGame.Game.Supervisor, [], id: :register_games,
        function: :register_games, restart: :temporary)
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
