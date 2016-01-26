defmodule Hanzo.Game.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def start_game(channel) do
    Supervisor.start_child(__MODULE__, [channel])
  end

  def init(:ok) do
    children = [
      worker(Hanzo.Game, [], restart: :transient)
    ]

    supervise(children, strategy: :simple_one_for_one)
  end
end