defmodule BotGame.Slack do
  @module ~S"""
  Our module for handling everything related to Slack communication.

  When `Slack.Client` connects to Slack, it will call `connect/1` with a
  reference to itself. This module should maintain that reference to the client
  at all times as we can't provide a global name for `Slack.Client`.
  """

  @token Application.get_env(:bot_game, __MODULE__)[:token]

  use GenServer
  require Logger

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    {:ok, []}
  end

  def connect(client_ref) do
    GenServer.cast(__MODULE__, {:connect, client_ref})
  end

  @doc ~S"""
  Called from `Slack.Client` with the message and slack reference.
  """
  def incoming_message(message, slack) do
    GenServer.cast(__MODULE__, {:incoming_message, message, slack})
  end

  @doc ~S"""
  Send outgoing messages to Slack. Channel is the string id of the Slack
  channel.
  """
  def send_message(message, channel) do
    GenServer.cast(__MODULE__, {:send_message, message, channel})
  end

  @doc ~S"""
  Send a direct message to a Slack user. ID is the user ID from Slack.
  """
  def send_dm(message, id) do
    GenServer.cast(__MODULE__, {:send_dm, message, id})
  end

  @doc ~S"""
  Sends an image to the specified channel. Requires a title and image URL.
  """
  def send_image(title, image_url, channel) do
    GenServer.cast(__MODULE__, {:send_image, title, image_url, channel})
  end

  @doc ~S"""
  Updates the reference to the Slack client.
  """
  def handle_cast({:connect, client_ref}, _state) do
    {:noreply, client_ref}
  end

  @doc ~S"""
  Dispatches incoming `type: message` messages to `BotGame.Commander`.

  Matches on whether it is a direct message or an @ message to the bot, and
  calls the appropriate function.
  """
  def handle_cast({:incoming_message, msg = %{type: "message"}, slack}, client_ref) do
    debug_message(msg)

    cond do
      String.starts_with?(msg.channel, "D") ->
        BotGame.Commander.direct_message(msg)
      String.starts_with?(msg.text, "<@#{slack.me.id}>:") && !String.starts_with?(msg.text, "D") ->
        BotGame.Commander.at_message(msg)
      true ->
        :ok
    end

    {:noreply, client_ref}
  end
  def handle_cast({:incoming_message, _msg, _slack}, client_ref) do
    {:noreply, client_ref}
  end

  @doc ~S"""
  Retrieves the user's DM channel, then forwards the message on.
  """
  def handle_cast({:send_dm, message, id}, client_ref) do
    channel = BotGame.Slack.Channel.direct_message(id)
    send_message(message, channel)
    {:noreply, client_ref}
  end

  @doc ~S"""
  Sends an attachment containing an image URL to the Slack API.
  """
  def handle_cast({:send_image, title, image_url, channel}, client_ref) do
    attachments =
      [%{title: title, fallback: title, text: "", image_url: image_url}]
      |> JSX.encode!()

    api_url("chat.postMessage") <> "&channel=#{channel}&as_user=true&attachments=#{attachments}"
    |> HTTPoison.get()

    {:noreply, client_ref}
  end

  @doc ~S"""
  Simple handoff to `Slack.Client`.
  """
  def handle_cast(message = {:send_message, _message, _channel}, client_ref) do
    send(client_ref, message)
    {:noreply, client_ref}
  end


  defp api_url(endpoint) do
    "https://slack.com/api/#{endpoint}?token=#{@token}"
  end

  defp debug_message(message) do
    msg = ["Incoming message"] ++ Enum.map(message, fn
      {k, v} when is_bitstring(v) ->
        "#{k}: #{v}"
      {k, _v} ->
        "#{k}: Can't print value"
    end)
    Logger.debug Enum.join(msg, "\n")
  end
end
