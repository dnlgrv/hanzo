defmodule Hanzo.Game.Player do
  use GenFSM
  alias Hanzo.Game.Player.Data
  import Hanzo.Slack, only: [send_dm: 2]

  @questions [
    %{
      id: "colour", text: "What's the best colour?", answers: [
        {"a", "Red"},
        {"b", "Blue"},
        {"c", "Green"}
      ]
    },

    %{
      id: "president", text: "Who's the president?", answers: [
        {"a", "Jesus"},
        {"b", "Obama"},
        {"c", "Dan"},
        {"d", "None of the above"}
      ]
    }
  ]

  def start_link(id, channel) do
    GenFSM.start_link(__MODULE__, Data.new(id, channel, @questions), name: via_tuple(id))
  end

  def answer(message) do
    case Hanzo.Registry.whereis_name(ref(message.user)) do
      :undefined -> :ok # user hasn't started playing
      pid -> :gen_fsm.sync_send_event(pid, message.text)
    end
  end

  # Callbacks

  def init(data) do
    {:ok, data.state, data, 0}
  end

  # States

  def start(:timeout, data) do
    send_dm("Welcome to the game!", data.id)
    data = Data.put_state(data, :question)
    {:next_state, data.state, data, 0}
  end

  def question(:timeout, data) do
    question = Enum.at(data.questions, data.current_question)

    if question do
      send_dm(question.text, data.id)
      Enum.each(question.answers, fn({k, v}) ->
        Hanzo.Slack.send_dm("#{k}. #{v}", data.id)
      end)

      data = Data.put_state(data, :await_answer)
      {:next_state, data.state, data}
    else
      data = Data.put_state(data, :finished)
      {:next_state, data.state, data, 0}
    end
  end

  def await_answer(message, _from, data) do
    question = Enum.at(data.questions, data.current_question)
    possible_answers = Enum.map(question.answers, fn({k, _v}) -> k end)

    answer =
      message
      |> String.first()
      |> String.downcase()

    case Enum.member?(possible_answers, answer) do
      true ->
        send_dm("You answered #{answer}!", data.id)
        data = Data.put_answer(data, answer)
        data = Data.put_state(data, :question)
        {:reply, :ok, data.state, data, 0}
      false ->
        send_dm("That wasn't a valid answer. Try again.", data.id)
        data = Data.put_state(data, :await_answer)
        {:reply, :ok, data.state, data}
    end
  end

  def finished(:timeout, data) do
    send_dm("You're all done! Once the results are in they'll be announced.", data.id)
    Hanzo.Game.player_finished(data.id, data.channel)
    {:next_state, data.state, data}
  end
  def finished(_message, _from, data) do
    send_dm("You're all done! Once the results are in they'll be announced.", data.id)
    {:reply, :ok, data.state, data}
  end

  # Private

  defp ref(id) do
    {:player, id}
  end

  defp via_tuple(id) do
    {:via, Hanzo.Registry, ref(id)}
  end
end
