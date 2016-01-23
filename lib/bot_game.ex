defmodule BotGame do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      supervisor(BotGame.Game.Supervisor, []),
      worker(BotGame.Slack, [])
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
