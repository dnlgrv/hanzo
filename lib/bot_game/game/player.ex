defmodule BotGame.Game.Player do
  use GenFSM
  alias BotGame.Game.Player.Data

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
    case BotGame.Registry.whereis_name({:player, message.user}) do
      :undefined -> :ok
      _ -> :gen_fsm.sync_send_event(via_tuple(message.user), message.text)
    end
  end

  # Callbacks

  def init(data) do
    BotGame.Slack.send_dm("Welcome to the game!", data.id)
    {:ok, :question, data, 0}
  end

  # States

  def question(:timeout, data) do
    question = Enum.at(data.questions, data.current_question)

    if question do
      BotGame.Slack.send_dm(question.text, data.id)
      Enum.each(question.answers, fn({k, v}) ->
        BotGame.Slack.send_dm("#{k}. #{v}", data.id)
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
        BotGame.Slack.send_dm("You answered #{answer}!", data.id)
        data = Data.put_answer(data, answer)
        {:reply, :ok, :question, data, 0}
      false ->
        BotGame.Slack.send_dm("That wasn't a valid answer. Try again.", data.id)
        {:reply, :ok, :await_answer, data}
    end
  end

  def finished(:timeout, data) do
    BotGame.Slack.send_dm("You're all done! Once the results are in they'll be announced.", data.id)
    {:next_state, :finished, data}
  end
  def finished(_message, _from, data) do
    BotGame.Slack.send_dm("You're all done! Once the results are in they'll be announced.", data.id)
    {:reply, :ok, :finished, data}
  end

  # Private

  defp via_tuple(id) do
    {:via, BotGame.Registry, {:player, id}}
  end
end
