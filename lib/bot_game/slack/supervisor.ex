defmodule BotGame.Slack.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    children = [
      worker(BotGame.Slack, []),
      worker(BotGame.Slack.Client, [BotGame.Slack])
    ]

    supervise(children, strategy: :one_for_one)
  end

  def handle_info(msg, state) do
    {:noreply, state}
  end
end
