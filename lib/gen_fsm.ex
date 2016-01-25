defmodule GenFSM do
  @moduledoc ~S"""
  A behaviour module for implementing a FSM server.

  ## Example

      defmodule Quiz do
        use GenFSM

        def init(:ok) do
          {:next_state, :play, []}
        end
      end

      # Start the server
      GenFSM.start_link(Quiz, name: Quiz)
  """

  defmacro __using__(_) do
    quote do
      @behaviour :gen_fsm
      @delay 50
      import GenFSM

      def code_change(_old_vsn, state_name, state_data, _extra) do
        {:ok, state_name, state_data}
      end

      def handle_event(_event, state_name, state_data) do
        {:next_state, state_name, state_data}
      end

      def handle_info(info, state_name, state_data) do
        {:next_state, state_name, state_data}
      end

      def handle_sync_event(_event, _from, state_name, state_data) do
        {:next_state, state_name, state_data}
      end

      def init(_args) do
        {:stop, "You need to implement init/1"}
      end

      def terminate(_reason, _state_name, _state_data) do
      end

      defoverridable [code_change: 4, handle_event: 3, handle_info: 3,
        handle_sync_event: 4, init: 1, terminate: 3]
    end
  end

  def start_link(mod, args \\ [], options \\ []) do
    {name, options} = Keyword.pop(options, :name, nil)

    case name do
      nil ->
        :gen_fsm.start_link(mod, args, options)
      _ ->
        :gen_fsm.start_link(name, mod, args, options)
    end
  end
end
