# listened for messages coming from the broker
defmodule BrokerListener do
  use GenServer

  @broker_port 2052
  @joiner_subscriber_port 2053


  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end


  def init(_) do
    # define the socket which will be used for communication and let it be the state of the GenServer
    # the GenServer is a module that has many handy methods, in special when working with sockets
    socket = :gen_udp.open(@joiner_subscriber_port, [:binary, active: true])
    socket
  end


  # this callback is called when some data is being sent to this subscriber from the broker
  def handle_info({:udp, _socket, _address, _port, data}, socket) do
    handle_packet(data, socket)
  end

  # decoding, then, depending on the structure of the data on of the handle_message f will be called
  # in this case we have only one because this subscriber is interested in only one type of message
  defp handle_packet(data, socket) do
    handle_message(Poison.decode!(data))
    {:noreply, socket}
  end


  defp handle_message(%{"action" => "feed", "data" => data}) do
    Joiner.join(data["sensor_data"])
  end


  # send a subscribe message to the broker
  def subscribe(topic) do
    socket = :sys.get_state(BrokerListener)
    message = %{:action => "subscribe", :topic => topic, :subscriber_port => @joiner_subscriber_port}
    :gen_udp.send(socket, {127,0,0,1}, @broker_port, Poison.encode!(message))
  end

  # send an unsubscribe message to the broker
  def unsubscribe(topic) do
    socket = :sys.get_state(BrokerListener)
    message = %{:action => "unsubscribe", :topic => topic, :subscriber_port => @joiner_subscriber_port}
    :gen_udp.send(socket, {127,0,0,1}, @broker_port, Poison.encode!(message))
  end

end