defmodule BotGame.Game.Player.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def new_player(id, game_id) do
    Supervisor.start_child(__MODULE__, [id, game_id])
  end

  def init(:ok) do
    children = [
      worker(BotGame.Game.Player, [], restart: :transient)
    ]

    supervise(children, strategy: :simple_one_for_one)
  end
end
