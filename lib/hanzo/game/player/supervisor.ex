defmodule Hanzo.Game.Player.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def new_player(id, channel) do
    Supervisor.start_child(__MODULE__, [id, channel])
  end

  def init(:ok) do
    children = [
      worker(Hanzo.Game.Player, [], restart: :transient)
    ]

    supervise(children, strategy: :simple_one_for_one)
  end
end
