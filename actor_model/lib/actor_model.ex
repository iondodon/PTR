defmodule ActorModel do

  def handle_event(id, event, data, dispatch_ts) do
    {:ok, pid} = Task.Supervisor.start_child(EventHandler, fn ->
      IO.inspect(id)
      IO.inspect(event)
      IO.inspect(data)
      IO.inspect(dispatch_ts)
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
    Supervisor.start_link([ {Task.Supervisor, name: EventHandler} ], strategy: :one_for_one)

    {:ok, pid} = EventsourceEx.new("http://localhost:4000/iot", stream_to: self())
    wait_for_event()
  end

end