# The spreader has the rote to send the messages collected in the queue to
# the subscribers which subscriber for specific topics
defmodule Spreader do
  @feeder_port 2060
  @topic "/sensors"

  # start a process in which an infinite loop will check if there is any message in the queue to be sent
  def start_link do
    # opening a port for communication with the subscribers
    {:ok, socket} = :gen_udp.open(@feeder_port)

    Task.start_link(fn -> feed_loop(socket) end)
  end


  defp feed_loop(socket) do
    # get queue state
    queue = MessageQueue.state()

    # check if there is any message in the queue
    if not :queue.is_empty(queue) do
      # extract one message from q
      {{:value, data}, new_queue} = :queue.out(queue)

      # kind on packet-convention of data format to be sent between broker and the others
      feed_message = %{:action => "feed", :data => data}

      # get the subscriptions registry
      subscriptions = SubscriptionsRegistry.state()

      Enum.each(subscriptions, fn {subscriber_port, topic} ->
        # for each subscription, check si the current message (extracted from the queue) is
        # reasonable to send to the subscriber from the subscription (subscription format : {topic, subscriber})
        if topic == data["topic"] do
          Task.async(fn -> send_to_subscriber(socket, subscriber_port, Poison.encode!(feed_message)) end)
        end
      end)

      MessageQueue.update(new_queue)
    end

    # repeat
    feed_loop(socket)
  end


  defp send_to_subscriber(socket, subscriber_port, feed) do
    IO.inspect("Send to subscriber #{subscriber_port}.")
    IO.inspect(feed)
    :gen_udp.send(socket, {127,0,0,1}, subscriber_port, feed)
  end

end