defmodule ActorModel do

  def prepare_supervisors() do
    # set event-handlers supervisor
    Supervisor.start_link([ {Task.Supervisor, name: EventHandler} ], strategy: :one_for_one)

    # set ForecastStation supervisor
    children = [ { ForecastStation, %{} } ]
    Supervisor.start_link(children, strategy: :one_for_all)
  end

  def process_event(id, event, data, dispatch_ts) do
#    {status, list} = JSON.decode(data)

#    IO.inspect(status)
#    IO.inspect(list)

    IO.inspect(dispatch_ts)
  end

  def handle_event(id, event, data, dispatch_ts) do
    {:ok, pid} = Task.Supervisor.start_child(EventHandler, fn ->
      process_event(id, event, data, dispatch_ts)
    end)
  end

  def wait_for_event() do
    receive do
      %EventsourceEx.Message{id: id, event: event, data: data, dispatch_ts: dispatch_ts}
        -> handle_event(id, event, data, dispatch_ts)
    end
    wait_for_event()
  end

  def run() do
    prepare_supervisors()

    {:ok, pid} = EventsourceEx.new("http://localhost:4000/iot", stream_to: self())

    wait_for_event()
  end

end