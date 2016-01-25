defmodule BotGame.Commander do
  @moduledoc ~S"""
  Handles all of the bot commands.

  This is probably not a very reusable module.
  """

  @doc ~S"""
  If the message is a direct message to the bot.
  """
  def direct_message(_message) do
  end

  @doc ~S"""
  If the message is @ the bot, but not in a direct message.
  """
  def at_message(message) do
    if String.contains?(message.text, "start game") do
      start_game(message.channel)
    end

    cond do
      String.contains?(message.text, "start game") ->
        start_game(message.channel)

      String.contains?(message.text, "play") ->
        play_game(message.channel, message.user)
    end
  end

  defp play_game(channel, id) do
    BotGame.Game.Player.Supervisor.start_player(channel, id)
  end

  defp start_game(channel) do
    BotGame.Game.Supervisor.start_game(channel)
  end
end
