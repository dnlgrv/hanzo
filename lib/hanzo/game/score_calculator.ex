defmodule Hanzo.Game.ScoreCalculator do
  def calculate(id) do
    questions = Hanzo.Parse.questions
    players = Hanzo.Parse.players(id)

    Enum.map(players, &(player_score(&1, questions)))
  end

  defp player_score(player, questions) do
    correct_answers =
      player.answers
      |> Enum.filter(fn(answer) ->
        question = Enum.find(questions, &(&1.key == answer.questionKey))
        answer.answer == question.correct_answer
      end)
      |> Enum.count

    score = correct_answers / Enum.count(player.answers)
    Map.put(player, :score, score)
  end
end
