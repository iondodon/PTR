# echo -n "hello world" | nc -4u -w1 localhost 2052
defmodule MessageListener do
  use GenServer

  def start_link(port \\ 2052) do
    GenServer.start_link(__MODULE__, port, name: __MODULE__)
  end

  def init(port) do
    :gen_udp.open(port, [:binary, active: true])
  end

  # externally called
  def handle_info({:udp, _socket, _address, _port, data}, socket) do
    # punt the data to a new function that will do pattern matching
    handle_packet(data, socket)
  end

  defp handle_packet(data, socket) do
    # print the message

    MessageQueue.update(:queue.in(data, MessageQueue.state()))

    # GenServer will understand this to mean "continue waiting for the next message"
    # parameters:
    # :noreply - no reply is needed
    # new_state: keep the socket as the current state
    {:noreply, socket}
  end
end