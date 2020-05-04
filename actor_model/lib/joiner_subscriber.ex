defmodule JoinerSubscriber do
  use GenServer

  @topic "/sensors/get"
  @recv_length 1024

  @broker_port 2052
  @joiner_subscriber_port 2053


  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end


  def init(state) do
    {:ok, state}
  end


  def listen_broker() do
    {:ok, socket} = :gen_udp.open(@joiner_subscriber_port)
    subscribe(socket, @topic)
    listen_broker_loop(socket)
  end


  defp listen_broker_loop(socket) do
    case :gen_udp.recv(socket, @recv_length) do
      {:ok, recv_data} ->
        IO.inspect(recv_data)
        listen_broker_loop(socket)
      {:error, reason} ->
        listen_broker_loop(socket)
    end
  end


  defp subscribe(socket, topic) do
    message = %{:action => "subscribe", :topic => topic, :subscriber_port => @joiner_subscriber_port}
    :gen_udp.send(socket, {127,0,0,1}, @broker_port, Poison.encode!(message))
  end


  def update_weather_description do
    old_state = ForecastStation.state()

    get_description = fn ->
      cond do
        old_state.temperature < -2 and old_state.light < 128 and old_state.atmo_pressure < 720 ->
          "SNOW"

        old_state.temperature < -2 and old_state.light > 128 and old_state.atmo_pressure < 680 ->
          "WET_SNOW"

        old_state.temperature < -8 ->
          "SNOW"

        old_state.temperature < -15 and old_state.wind_speed > 45 ->
          "BLIZZARD"

        old_state.temperature > 0 and old_state.atmo_pressure < 710 and old_state.humidity > 70 and
        old_state.wind_speed < 20 ->
          "SLIGHT_RAIN"

        old_state.temperature > 0 and old_state.atmo_pressure < 690 and old_state.humidity > 70 and
        old_state.wind_speed > 20 ->
          "HEAVY_RAIN"

        old_state.temperature > 30 and old_state.atmo_pressure < 770 and old_state.humidity > 80 and
        old_state.light > 192 ->
          "HOT"

        old_state.temperature > 30 and old_state.atmo_pressure < 770 and old_state.humidity > 50 and
        old_state.light > 192 and old_state.wind_speed > 35 ->
          "CONVECTION_OVEN"

        old_state.temperature > 25 and old_state.atmo_pressure < 750 and old_state.humidity > 70 and
        old_state.light < 192 and old_state.wind_speed < 10 ->
          "WARM"

        old_state.temperature > 25 and old_state.atmo_pressure < 750 and old_state.humidity > 70 and
        old_state.light < 192 and old_state.wind_speed > 10 ->
          "SLIGHT_BREEZE"

        old_state.light < 128 ->
          "CLOUDY"

        old_state.temperature > 30 and old_state.atmo_pressure < 660 and old_state.humidity > 85 and
        old_state.wind_speed > 45 ->
          "MONSOON"

        true ->
          "JUST_A_NORMAL_DAY"
      end
    end

    ForecastStation.update(%{old_state | :description => get_description.()})
  end

end