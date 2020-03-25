defmodule EventsHandler do
  use Task

  def start_link(arg) do
    Task.start_link(__MODULE__, :run, [arg])
  end

  def handle_event(supervisor_pid, new_state) do
    # dynamically create tasks
    event_handler = Task.Supervisor.async(supervisor_pid, fn ->
      if elem(new_state[:data], 0) === :ok do
        StateManager.start_link(elem(new_state[:data], 1))
      end
    end)

    if elem(new_state[:data], 0) === :error do
      # shutdown the process when panic
      Task.shutdown(event_handler, 0)
    end
  end

  def wait_for_event(supervisor_pid) do
    receive do
      %EventsourceEx.Message{id: id, event: event, data: data, dispatch_ts: dispatch_ts}
        -> handle_event(supervisor_pid, %{:id => id, :event => event, :data => JSON.decode(data), :dispatch_ts => dispatch_ts })
    end

    # infinite loop
    wait_for_event(supervisor_pid)
  end

  def run(arg) do
    # set ForecastStation and StateManager supervisor
    children = [ { ForecastStation, %{:updated_at => nil, :weather => "JUST_A_NORMAL_DAY"} }, { StateManager, nil } ]
    Supervisor.start_link(children, strategy: :one_for_all)

    {:ok, pid} = EventsourceEx.new("http://localhost:4000/iot", stream_to: self())

    # set event-handlers supervisor
    {:ok, supervisor_pid} = Task.Supervisor.start_link()
    wait_for_event(supervisor_pid)
  end

end