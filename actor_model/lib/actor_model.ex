defmodule ActorModel do

  def show(id, event, data, dispatch_ts) do
    IO.puts(id)
    IO.puts(event)
    IO.puts(data)
    IO.puts(dispatch_ts)
  end

  def handle() do
    receive do
      %EventsourceEx.Message{id: id, event: event, data: data, dispatch_ts: dispatch_ts}
        -> show(id, event, data, dispatch_ts)
    end
    handle()
  end

  def main do
    {:ok, pid} = EventsourceEx.new("http://localhost:4000/iot", stream_to: self())
    handle()
  end

end