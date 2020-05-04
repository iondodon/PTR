defmodule Broker do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(state) do
    feed_loop()
    {:ok, state}
  end

  def feed_loop() do
    queue = MessageQueue.state()
    if not :queue.is_empty(queue) do
      {element, new_queue} = :queue.out(queue)
      MessageQueue.update(new_queue)
    end
    feed_loop()
  end
end