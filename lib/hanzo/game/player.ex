defmodule Hanzo.Game.Player do
  use GenFSM
  alias Hanzo.Game.Player.Data

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

  def start_link(id, game_id) do
    GenFSM.start_link(__MODULE__, Data.new(id, game_id, @questions), name: via_tuple(id))
  end

  def answer(message) do
    case Hanzo.Registry.whereis_name(ref(message.user)) do
      :undefined -> :ok # user hasn't started playing
      pid -> :gen_fsm.sync_send_event(pid, message.text)
    end
  end

  # Callbacks

  def init(data) do
    Hanzo.Slack.send_dm("Welcome to the game!", data.id)
    {:ok, :question, data, 0}
  end

  # States

  def question(:timeout, data) do
    question = Enum.at(data.questions, data.current_question)

    if question do
      Hanzo.Slack.send_dm(question.text, data.id)
      Enum.each(question.answers, fn({k, v}) ->
        Hanzo.Slack.send_dm("#{k}. #{v}", data.id)
      end)
      {:next_state, :await_answer, data}
    else
      {:next_state, :finished, data, 0}
    end
  end

  def await_answer(message, _from, data) do
    question = Enum.at(data.questions, data.current_question)
    possible_answers = Enum.map(question.answers, fn({k, _v}) -> k end)

    answer = String.first(message)

    case Enum.member?(possible_answers, answer) do
      true ->
        Hanzo.Slack.send_dm("You answered #{answer}!", data.id)
        data = Data.put_answer(data, answer)
        {:reply, :ok, :question, data, 0}
      false ->
        Hanzo.Slack.send_dm("That wasn't a valid answer. Try again.", data.id)
        {:reply, :ok, :await_answer, data}
    end
  end

  def finished(:timeout, data) do
    Hanzo.Slack.send_dm("You're all done! Once the results are in they'll be announced.", data.id)
    {:next_state, :finished, data}
  end
  def finished(_message, _from, data) do
    Hanzo.Slack.send_dm("You're all done! Once the results are in they'll be announced.", data.id)
    {:reply, :ok, :finished, data}
  end

  # Private

  defp ref(id) do
    {:player, id}
  end

  defp via_tuple(id) do
    {:via, Hanzo.Registry, ref(id)}
  end
end
