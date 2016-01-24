defmodule BotGame.Player do
  use GenFSM

  def start_link(id) do
    GenFSM.start_link(__MODULE__, [], name: {:global, {:player, id}})
  end

  def init(state_data) do
    {:ok, :question, state_data}
  end

  # States

  def question({:message, message, _slack}, state_data) do
    {:next_state, :question, state_data}
  end
end
