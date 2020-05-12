defmodule MessageListener do
  use GenServer

  def start_link(port \\ 2052) do
    GenServer.start_link(__MODULE__, port, name: __MODULE__)
  end

  def init(port) do
    :gen_udp.open(port, [:binary, active: true])
  end

  # externally called
  # each incoming data come through this callback, then it is forwarded to handle_packet for decoding
  def handle_info({:udp, _socket, _address, _port, data}, socket) do
    # punt the data to a new function that will do pattern matching
    handle_packet(data, socket)
  end

  defp handle_packet(data, socket) do
    data = Poison.decode!(data)
    IO.inspect("Received:")
    IO.inspect(data)

    #depending on the structure of the data, one of the handle_message f will be called
    # each handle_message understand what type of message it is and knows what to do
    handle_message(data)

    # GenServer will understand this to mean "continue waiting for the next message"
    # parameters:
    # :noreply - no reply is needed
    # new_state: keep the socket as the current state
    {:noreply, socket}
  end


  defp handle_message(%{"action" => "feed_broker", "data" => data}) do
    # insert the new feed in the queue
    MessageQueue.update(:queue.in(data, MessageQueue.state()))
  end

  # create a new subscription and put it in the subscriptions registry
  defp handle_message(%{"action" => "subscribe", "topic" => topic, "subscriber_port" => subscriber_port}) do
    registry = SubscriptionsRegistry.state()
    new_registry = registry ++ [{subscriber_port, topic}]
    SubscriptionsRegistry.update(new_registry)
    IO.inspect("Service on port #{subscriber_port} has subscribed on topic #{topic}.")
  end

  # remove a subscription from the registry
  defp handle_message(%{"action" => "unsubscribe", "topic" => topic, "subscriber_port" => subscriber_port}) do
    registry = SubscriptionsRegistry.state()
    new_registry = registry -- [{subscriber_port, topic}]
    SubscriptionsRegistry.update(new_registry)
    IO.inspect("Service on port #{subscriber_port} has unsubscribed on topic #{topic}.")
  end
end
