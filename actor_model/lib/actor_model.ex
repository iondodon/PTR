defmodule ActorModel do

  def prepare_supervisors() do
    # set event-handlers supervisor
    Supervisor.start_link([ {Task.Supervisor, name: EventHandler} ], strategy: :one_for_one)

    # set ForecastStation and StateManager supervisor
    children = [ { ForecastStation, %{} }, { StateManager, %{} } ]
    Supervisor.start_link(children, strategy: :one_for_all)
  end

  def handle_event(new_state) do
    {:ok, pid} = Task.Supervisor.start_child(EventHandler, fn pid ->
      case elem(new_state[:data], 0) do
        :ok -> StateManager.start_link(new_state)   # the ok case
        :error -> Process.exit(pid, :kill)          # the panic case
      end
    end)
  end

  def wait_for_event() do
    receive do
      %EventsourceEx.Message{id: id, event: event, data: data, dispatch_ts: dispatch_ts}
        -> handle_event(%{:id => id, :event => event, :data => JSON.decode(data), :dispatch_ts => dispatch_ts })
    end
    wait_for_event()
  end

  def run() do
    prepare_supervisors()

    {:ok, pid} = EventsourceEx.new("http://localhost:4000/iot", stream_to: self())

    wait_for_event()
  end

end