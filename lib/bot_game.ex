defmodule BotGame do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      worker(BotGame.Registry, []),
      supervisor(BotGame.Slack.Supervisor, []),
      supervisor(BotGame.Game.Supervisor, []),
      supervisor(BotGame.Game.Player.Supervisor, [])
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
