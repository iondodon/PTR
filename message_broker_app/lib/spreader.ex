defmodule Spreader do
  @feeder_port 2060
  @topic "/sensors"

  def start_link do
    {:ok, socket} = :gen_udp.open(@feeder_port)
    Task.start_link(fn -> feed_loop(socket) end)
  end


  defp feed_loop(socket) do
    queue = MessageQueue.state()
    if not :queue.is_empty(queue) do
      {{:value, data}, new_queue} = :queue.out(queue)

      feed_message = %{:action => "feed", :data => data}
      subscriptions = SubscriptionsRegistry.state()
      Enum.each(subscriptions, fn {subscriber_port, topic} ->
        if topic == data["topic"] do
          Task.async(fn -> send_to_subscriber(socket, subscriber_port, Poison.encode!(feed_message)) end)
        end
      end)

      MessageQueue.update(new_queue)
    end
    feed_loop(socket)
  end


  defp send_to_subscriber(socket, subscriber_port, feed) do
    IO.inspect("Send to subscriber #{subscriber_port}.")
    IO.inspect(feed)
    :gen_udp.send(socket, {127,0,0,1}, subscriber_port, feed)
  end

end