defmodule Hanzo.Mixfile do
  use Mix.Project

  def project do
    [app: :hanzo,
     version: "0.0.1",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  def application do
    [applications: [:logger, :slack, :httpoison, :parse_client],
     mod: {Hanzo, []}]
  end

  defp deps do
    [{:slack, git: "https://github.com/cazrin/Elixir-Slack.git", branch: "relaxed-http-poison-version"},
     {:websocket_client, git: "https://github.com/jeremyong/websocket_client.git"},
     {:httpoison, ">= 0.7.0", override: true},
     {:exjsx, "~> 3.1.0"},
     {:parse_client, git: "https://github.com/cazrin/parse_elixir_client", branch: "no-bang-atoms"}]
  end
end
