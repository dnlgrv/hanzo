defmodule BotGame do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      supervisor(BotGame.Slack.Supervisor, []),
      supervisor(BotGame.Game.Supervisor, [])
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
