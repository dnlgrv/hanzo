defmodule BotGame.Mixfile do
  use Mix.Project

  def project do
    [app: :bot_game,
     version: "0.0.1",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  def application do
    [applications: [:logger, :slack],
     mod: {BotGame, []}]
  end

  defp deps do
    [#{:slack, "~> 0.4.0"},
     {:slack, git: "https://github.com/cazrin/Elixir-Slack", branch: "fix-handle-info-to-update-state"},
     {:websocket_client, git: "https://github.com/jeremyong/websocket_client.git"}]
  end
end
