defmodule Hanzo do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      worker(Hanzo.Registry, []),
      supervisor(Hanzo.Slack.Supervisor, []),
      supervisor(Hanzo.Game.Supervisor, []),
      supervisor(Hanzo.Game.Player.Supervisor, [])
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
