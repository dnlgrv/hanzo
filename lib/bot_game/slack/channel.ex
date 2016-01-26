defmodule Hanzo.Slack.Channel do
  @moduledoc ~S"""
  Stores references to DM channels for users.

  If there's no reference, one will be retrieved using Slack's HTTP API.
  """

  use GenServer

  @token Application.get_env(:hanzo, Hanzo.Slack)[:token]

  def start_link do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def direct_message(id) do
    GenServer.call(__MODULE__, {:direct_message, id})
  end


  def handle_call({:direct_message, id}, _from, channels) do
    case Map.get(channels, id) do
      nil ->
        case channel_from_api(id) do
          {:ok, channel} ->
            {:reply, channel, Map.put(channels, id, channel)}
          _ -> nil
        end

      channel ->
        {:reply, channel, channels}
    end
  end

  defp channel_from_api(id) do
    case HTTPoison.get("https://slack.com/api/im.open?user=" <> id <> "&token=" <> @token) do
      {:ok, response} ->
        json = JSX.decode!(response.body, [{:labels, :atom}])
        {:ok, json.channel.id}
      error -> error
    end
  end
end
