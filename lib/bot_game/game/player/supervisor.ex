defmodule BotGame.Game.Player.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def start_player(channel, id) do
    Supervisor.start_child(__MODULE__, [channel, id])
  end

  def init(:ok) do
    children = [
      worker(BotGame.Game.Player, [], restart: :transient)
    ]

    supervise(children, strategy: :simple_one_for_one)
  end
end
