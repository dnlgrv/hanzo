defmodule BotGame.Game do
  @behaviour :gen_fsm

  import Slack, only: [send_message: 3]
  alias :gen_fsm, as: FSM

  # States

  def start(_event, state = {channel, slack}) do
    send_message("Game started.", channel, slack)
    {:next_state, :question, state, 2000}
  end

  def question(_event, state = {channel, slack}) do
    send_message("Who is the best?", channel, slack)
    {:next_state, :await_answer, state}
  end

  def await_answer(event, state = {channel, slack}) do
    if event.text == "Daniel" do
      send_message("Correct!", channel, slack)
      {:stop, :normal, state}
    else
      send_message("Wrong!", channel, slack)
      {:next_state, :question, state, 2000}
    end
  end

  # GenServer

  def start_link(channel, slack, name) do
    FSM.start_link(ref(name), __MODULE__, {channel, slack}, [])
  end

  def init(state = {channel, slack}) do
    {:ok, :start, state, 0}
  end

  # Public API

  def handle_message(message) do
    FSM.send_event(ref(message.user), message)
  end

  def stop(name) do
    FSM.stop(ref(name), :normal, :infinity)
  end

  # Callbacks

  def terminate(_reason, _state, {channel, slack}) do
    send_message("Game stopped.", channel, slack)
    :ok
  end


  defp ref(name), do: {:global, {:game, name}}
end
