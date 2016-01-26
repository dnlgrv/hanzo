defmodule Hanzo.Game.Data do
  @moduledoc ~S"""
  Acts as a simple interface for handling game state data.

  Trying out using `:ets` here to recover data from crashes. Seems to be
  working well at the moment. Will want to make the interface for it better
  than it currently is though. For example, the ETS table is currently public
  (not great).
  """

  defstruct channel: nil, players: [], state: :start

  def new(channel) do
    case :ets.lookup(:game_data, channel) do
      [] ->
        data = %__MODULE__{channel: channel}
        :ets.insert(:game_data, {channel, data})
        data
      [{^channel, data}] ->
        data
    end
  end

  def put_player(data, player) do
    data = %{data | players: [player | data.players]}
    :ets.insert(:game_data, {data.channel, data})
    data
  end

  def put_state(data, state) do
    data = %{data | state: state}
    :ets.insert(:game_data, {data.channel, data})
    data
  end
end
