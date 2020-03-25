defmodule ActorModel do

  def handle_event(supervisor_pid, new_state) do
    event_handler = Task.Supervisor.async(supervisor_pid, fn ->
      StateManager.start_link(new_state)
    end)

    if elem(new_state[:data], 0) === :error do
      Task.shutdown(event_handler, 0)
    end
  end

  def wait_for_event() do
    # set event-handlers supervisor
    {:ok, supervisor_pid} = Task.Supervisor.start_link()

    receive do
      %EventsourceEx.Message{id: id, event: event, data: data, dispatch_ts: dispatch_ts}
        -> handle_event(supervisor_pid, %{:id => id, :event => event, :data => JSON.decode(data), :dispatch_ts => dispatch_ts })
    end
    wait_for_event()
  end

  def run() do
    # set ForecastStation and StateManager supervisor
    children = [ { ForecastStation, %{} }, { StateManager, %{} } ]
    Supervisor.start_link(children, strategy: :one_for_all)

    {:ok, pid} = EventsourceEx.new("http://localhost:4000/iot", stream_to: self())

    wait_for_event()
  end

end