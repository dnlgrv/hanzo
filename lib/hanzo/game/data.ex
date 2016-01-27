defmodule Hanzo.Game.Data do
  @moduledoc ~S"""
  Acts as a simple interface for handling game state data.

  Trying out using `:ets` here to recover data from crashes. Seems to be
  working well at the moment. Will want to make the interface for it better
  than it currently is though. For example, the ETS table is currently public
  (not great).
  """

  defstruct channel: nil, players: [], players_finished: [],
  state: :start

  def new(channel) do
    case :ets.lookup(:game_data, channel) do
      [] ->
        %__MODULE__{channel: channel}
        |> persist()
      [{^channel, data}] ->
        data
    end
  end

  def put_player(data, player) do
    %{data | players: [player | data.players]}
    |> persist()
  end

  def put_player_finished(data, player) do
    Hanzo.Parse.save_player_data(player)
    %{data | players_finished: [player | data.players_finished]}
    |> persist()
  end

  def put_state(data, state) do
    %{data | state: state}
    |> persist()
  end

  defp persist(data) do
    :ets.insert(:game_data, {data.channel, data})
    data
  end
end
