defmodule BotGame.Game do
  use GenFSM

  @instructions [
    "We're starting a game!",
    "If you want to play, message me with 'play'",
    "When everyone has finished playing, I'll announce the winner"
  ]

  def start_link do
    GenFSM.start_link(__MODULE__, %{}, name: {:global, {:game, __MODULE__}})
  end

  def init(state_data) do
    {:ok, :not_playing, state_data}
  end

  # States

  def not_playing({:message, message, slack}, state_data) do
    if at_bot(message, slack) =~ "start" do
      {:next_state, :send_instructions, {message.channel, slack, @instructions}, 0}
    else
      {:next_state, :not_playing, state_data}
    end
  end


  def send_instructions(_event, {channel, slack, []}) do
    {:next_state, :playing, {channel, slack, []}}
  end
  def send_instructions(_event, {channel, slack, instructions}) do
    [instruction | instructions] = instructions
    Slack.send_message(instruction, channel, slack)
    {:next_state, :send_instructions, {channel, slack, instructions}, 200}
  end


  def playing({:message, message, slack}, state_data) do
    {:ok, state_data} = handle_playing_message(message, slack, state_data)
    {:next_state, :playing, state_data}
  end

  # Private

  defp handle_playing_message(message = %{
    channel: <<"D", _rest::binary>>, text: "play", user: user
  }, slack, {s_chan, s_slack, players}) do
    unless player_ref(user) do
      BotGame.Player.Supervisor.start_player(user)
      players = [user | players]
    end

    {:ok, {s_chan, s_slack, players}}
  end
  defp handle_playing_message(message = %{
    channel: <<"D", _rest::binary>>, user: user
  }, slack, state_data) do
    if ref = player_ref(user) do
      send(ref, {:message, message, slack})
    end

    {:ok, state_data}
  end
  defp handle_playing_message(_message, _slack, state_data), do: {:ok, state_data}

  defp at_bot(message, slack) do
    id = slack.me.id

    if String.contains?(message.text, "<@#{id}>:") do
      String.downcase(message.text)
    else
      ""
    end
  end

  defp player_ref(id) do
    case :global.whereis_name({:player, id}) do
      :undefined -> nil
      ref -> ref
    end
  end
end
