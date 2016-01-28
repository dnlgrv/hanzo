defmodule Hanzo.Parse do
  @moduledoc ~S"""
  Module for interacting with Parse.
  """

  @doc ~S"""
  Gets the player's data from ETS and saves it to Parse.

  Removes the player's previous answers if there are any.
  """
  def save_player_data(id) do
    [{^id, data}] = :ets.lookup(:player_data, id)

    player_id = case get_player(id) do
      nil -> create_player(data)
      player -> player.objectId
    end

    player_id
    |> delete_answers()
    |> create_answers(data)
  end

  def create_answers(id, data) do
    Enum.each(data.answers, fn({key, answer}) ->
      ParseClient.post("classes/PlayerAnswer", %{
        "playerId" => %{"__type" => "Pointer", "className" => "Player", "objectId" => id},
        "questionKey" => key,
        "answer" => answer
      })
    end)
  end

  @doc ~S"""
  Gets the questions and the possible answers, building up a map.
  """
  def questions do
    ParseClient.query("classes/Question", %{})
    |> Map.get(:results)
    |> Enum.sort_by(&(&1.order))
    |> Enum.map(fn(question) ->
      question_object = %{"__type" => "Pointer", "className" => "Question", "objectId" => question.objectId}

      answers =
        ParseClient.query("classes/QuestionAnswer", %{"$relatedTo" => %{object: question_object, key: "answers"}})
        |> Map.get(:results)
        |> Enum.sort_by(&(&1.key))
        |> Enum.map(fn(answer) ->
          {answer.key, answer.value}
        end)

      %{
        key: question.key,
        text: question.text,
        answers: answers
      }
    end)
  end

  defp create_player(data) do
    player = ParseClient.post("classes/Player", %{"slackId" => data.id, "channelId" => data.channel})
    player.body.objectId
  end

  defp delete_answers(id) do
    %{results: results} = ParseClient.query("classes/PlayerAnswer", %{"playerId" => %{"__type" => "Pointer", "className" => "Player", "objectId" => id}})
    Enum.each(results, &(ParseClient.delete("classes/PlayerAnswer/#{&1.objectId}")))
    id
  end

  defp get_player(id) do
    case ParseClient.query("classes/Player", %{"slackId" => id}) do
      %{results: []} -> nil
      %{results: results} -> List.first(results)
    end
  end
end
