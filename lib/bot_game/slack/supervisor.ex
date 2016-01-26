defmodule Hanzo.Slack.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    children = [
      worker(Hanzo.Slack, []),
      worker(Hanzo.Slack.Channel, []),
      worker(Hanzo.Slack.Client, [Hanzo.Slack])
    ]

    supervise(children, strategy: :one_for_one)
  end
end
