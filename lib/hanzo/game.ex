defmodule Hanzo.Game do
  use GenFSM

  alias Hanzo.Game.Data
  import Hanzo.Slack, only: [send_message: 2]

  def start_link(channel) do
    GenFSM.start_link(__MODULE__, Data.new(channel), name: via_tuple(channel))
  end

  def init(data) do
    {:ok, data.state, data, 0}
  end

  def calculate_scores(channel) do
    case Hanzo.Registry.whereis_name(ref(channel)) do
      :undefined -> :ok # Game isn't running
      pid -> :gen_fsm.send_event(pid, :calculate_scores)
    end
  end

  def new_player(user, channel) do
    case Hanzo.Registry.whereis_name(ref(channel)) do
      :undefined -> :ok # Game isn't running
      pid -> :gen_fsm.send_event(pid, {:new_player, user})
    end
  end

  def player_finished(user, channel) do
    case Hanzo.Registry.whereis_name(ref(channel)) do
      :undefined -> :ok # Game isn't running
      pid -> :gen_fsm.send_event(pid, {:player_finished, user})
    end
  end

  # States

  def start(:timeout, data) do
    send_message("Game started.\nIf you want to participate, just @ me saying 'play'.", data.channel)
    data = Data.put_state(data, :playing)
    data = Data.put_questions(data, fetch_questions)
    {:next_state, data.state, data, 0}
  end

  def playing({:new_player, id}, data) do
    # Don't want a player starting 2 games
    unless Enum.member?(data.players, id) do
      data = add_new_player(data, id, data.questions)
    end

    {:next_state, data.state, data}
  end
  def playing({:player_finished, id}, data) do
    # Don't want them being "finished" twice
    unless Enum.member?(data.players_finished, id) do
      data = Data.put_player_finished(data, id)
    end

    {:next_state, data.state, data}
  end
  def playing(:calculate_scores, data) do
    send_message("The scores are in:\n", data.channel)

    Hanzo.Game.ScoreCalculator.calculate(data.channel)
    |> Enum.sort_by(&(&1.score))
    |> Enum.reverse
    |> Enum.with_index(1)
    |> Enum.each(fn({player, index}) ->
      send_message("#{index}. <@#{player.slackId}> scored #{player.score*100}%", data.channel)
    end)

    {:next_state, :finished, data, 0}
  end
  def playing(_msg, data) do
    {:next_state, data.state, data}
  end

  def finished(_msg, data) do
    {:stop, :normal, []}
  end

  # Private

  defp add_new_player(data, id, questions) do
    case Hanzo.Game.Player.Supervisor.new_player(id, data.channel, questions) do
      {:ok, _} ->
        send_message("<@#{id}> has joined the game!", data.channel)
        data = Data.put_player(data, id)
      _ -> :ok
    end

    data
  end

  defp fetch_questions do
    Hanzo.Parse.questions
  end

  defp ref(channel) do
    {:game, channel}
  end

  defp via_tuple(channel) do
    {:via, Hanzo.Registry, ref(channel)}
  end
end
