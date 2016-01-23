defmodule BotGame.Game.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def start_game(slack) do
    Supervisor.start_child(__MODULE__, [slack])
  end

  def init(:ok) do
    children = [
      worker(BotGame.Game, [], restart: :temporary)
    ]

    supervise(children, strategy: :simple_one_for_one)
  end
end
