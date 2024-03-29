defmodule Hanzo.Commander do
  @moduledoc ~S"""
  Handles all of the bot commands.

  This is probably not a very reusable module.
  """

  @doc ~S"""
  If the message is a direct message to the bot.
  """
  def direct_message(message) do
    Hanzo.Game.Player.answer(message)
  end

  @doc ~S"""
  If the message is @ the bot, but not in a direct message.
  """
  def at_message(message) do
    cond do
      String.contains?(message.text, "start game") ->
        Hanzo.Game.Supervisor.start_game(message.channel)

      String.contains?(message.text, "play") ->
        Hanzo.Game.new_player(message.user, message.channel)

      true -> :ok
    end
  end
end
