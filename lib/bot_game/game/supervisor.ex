defmodule BotGame.Game.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    children = [
      worker(BotGame.Game, [])
    ]

    supervise(children, strategy: :one_for_one)
  end

  def register_games do
    {:ok, spawn fn ->
      :global.whereis_name({:game, BotGame.Game})
      |> BotGame.Slack.Dispatcher.register()
    end}
  end
end
