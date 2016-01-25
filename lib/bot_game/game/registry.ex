defmodule BotGame.Registry do
  use GenServer
  import Kernel, except: [send: 2]

  def start_link do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def register_name(key, pid) do
    GenServer.call(__MODULE__, {:register_name, key, pid})
  end

  def send(key, message) do
    case whereis_name(key) do
      :undefined -> {:badarg, {key, message}}
      pid ->
        Kernel.send(pid, message)
        pid
    end
  end

  def unregister_name(key) do
    GenServer.call(__MODULE__, {:unregister_name, key})
  end

  def whereis_name(key) do
    GenServer.call(__MODULE__, {:whereis_name, key})
  end


  def init(nil) do
    {:ok, %{}}
  end

  def handle_call({:register_name, key, pid}, _from, registry) do
    case Map.get(registry, key) do
      nil ->
        Process.monitor(pid)
        {:reply, :yes, Map.put(registry, key, pid)}
      _ ->
        {:reply, :no, registry}
    end
  end

  def handle_call({:unregister_name, key}, _from, registry) do
    {:reply, key, Map.delete(registry, key)}
  end

  def handle_call({:whereis_name, key}, _from, registry) do
    {:reply, Map.get(registry, key, :undefined), registry}
  end

  def handle_info({:DOWN, _ref, :process, pid, _}, registry) do
    {:noreply, deregister_pid(registry, pid)}
  end

  defp deregister_pid(registry, pid) do
    Enum.reduce(registry, registry, fn
      ({key, ^pid}, acc) ->
        Map.delete(acc, key)

      (_, acc) -> acc
    end)
  end
end
