defmodule BotGame.Game.Player.Data do
  defstruct id: nil, game_id: nil, answers: %{}, questions: [],
  current_question: 0

  def new(id, game_id, questions) do
    %__MODULE__{id: id, game_id: game_id, questions: questions}
  end

  def put_answer(data, answer) do
    current_question = Enum.at(data.questions, data.current_question)
    answers = data.answers |> Map.put(current_question.id, answer)

    data = Map.put(data, :answers, answers)
    data = Map.put(data, :current_question, data.current_question + 1)

    data
  end
end
