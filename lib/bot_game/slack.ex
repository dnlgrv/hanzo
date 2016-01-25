defmodule BotGame.Slack do
  @module ~S"""
  Our module for handling everything related to Slack communication.

  When `Slack.Client` connects to Slack, it will call `connect/1` with a
  reference to itself. This module should maintain that reference to the client
  at all times as we can't provide a global name for `Slack.Client`.
  """

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


  def handle_cast({:connect, client_ref}, _state) do
    {:noreply, client_ref}
  end

  def handle_cast({:incoming_message, message, _slack}, client_ref) do
    # Do something with an incoming message
    debug_message(message)
    {:noreply, client_ref}
  end

  def handle_cast(message = {:send_message, _message, _channel}, client_ref) do
    send(client_ref, message)
    {:noreply, client_ref}
  end


  defp debug_message(message) do
    msg = ["Incoming message"] ++ Enum.map(message, fn ({k, v}) ->
      "#{k}: #{v}"
    end)
    Logger.debug Enum.join(msg, "\n")
  end
end
