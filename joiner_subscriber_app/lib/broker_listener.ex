defmodule BrokerListener do
  use GenServer

  @broker_port 2052
  @joiner_subscriber_port 2053


  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end


  def init(_) do
    socket = :gen_udp.open(@joiner_subscriber_port, [:binary, active: true])
    socket
  end


  def handle_info({:udp, _socket, _address, _port, data}, socket) do
    handle_packet(data, socket)
  end


  defp handle_packet(data, socket) do
    handle_message(Poison.decode!(data))
    {:noreply, socket}
  end


  defp handle_message(%{"action" => "feed", "data" => data}) do
    sensors_input = data["sensor_data"]
    # TODO: to improve this
    IO.inspect Enum.each(Map.keys(sensors_input), fn key ->
      sensors_state = ForecastStation.state()
      sensors_state = Map.put(sensors_state, key, sensors_input[key])
      ForecastStation.update(sensors_state)
    end)
    IO.inspect(ForecastStation.state())
  end


  def subscribe(topic) do
    socket = :sys.get_state(BrokerListener)
    message = %{:action => "subscribe", :topic => topic, :subscriber_port => @joiner_subscriber_port}
    :gen_udp.send(socket, {127,0,0,1}, @broker_port, Poison.encode!(message))
  end

end