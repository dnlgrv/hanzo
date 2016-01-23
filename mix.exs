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
    [{:slack, "~> 0.4.0"},
     {:websocket_client, github: "sanmiguel/websocket_client"}]
  end
end
