defmodule Hanzo.Parse do
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
