defmodule PreBrokerProcessor do
  use Task
  @broker_port 2052
  @state_manager_port 2055


  def start_link(sensors) do
    Task.start_link(__MODULE__, :run, [sensors])
  end


  def run(sensors) do
    if Map.has_key?(sensors, "wind_speed_sensor_1") and
         Map.has_key?(sensors, "atmo_pressure_sensor_1") do
      atmo_pressure = (sensors["atmo_pressure_sensor_1"] + sensors["atmo_pressure_sensor_2"]) / 2
      wind_speed = (sensors["wind_speed_sensor_1"] + sensors["wind_speed_sensor_2"]) / 2
      timestamp = sensors["unix_timestamp_100us"]

      sensor_data = %{
        :atmo_pressure => atmo_pressure,
        :wind_speed => wind_speed,
        :timestamp => timestamp
      }

      send_to_broker(sensor_data)
    end


    if Map.has_key?(sensors, "light_sensor_1") do
      light = (sensors["light_sensor_1"] + sensors["light_sensor_2"]) / 2
      timestamp = sensors["unix_timestamp_100us"]

      sensor_data = %{
        :light => light,
        :timestamp => timestamp
      }

      send_to_broker(sensor_data)
    end

    if Map.has_key?(sensors, "SensorReadings") do
      content = sensors["SensorReadings"]["#content"]

      [humidity_percent0, humidity_percent1] = content["humidity_percent"]["value"]
      [temperature_celsius0, temperature_celsius1] = content["temperature_celsius"]["value"]
      timestamp = sensors["SensorReadings"]["-unix_timestamp_100us"]

      {humidity_percent0, _} = Float.parse(humidity_percent0)
      {humidity_percent1, _} = Float.parse(humidity_percent1)
      {temperature_celsius0, _} = Float.parse(temperature_celsius0)
      {temperature_celsius1, _} = Float.parse(temperature_celsius1)
      {timestamp, _} = Integer.parse(timestamp)

      humidity = (humidity_percent0 + humidity_percent1) / 2
      temperature = (temperature_celsius0 + temperature_celsius1) / 2

      sensor_data = %{
        :humidity => humidity,
        :temperature => temperature,
        :timestamp => timestamp
      }

      send_to_broker(sensor_data)
    end

  end


  defp send_to_broker(sensor_data) do
    message = %{:action => "feed_broker", :data => %{:topic => "/sensors", :sensor_data => sensor_data}}

    IO.inspect(message)

    # TODO: to fix this
    case :gen_udp.open(@state_manager_port) do
      {:ok, socket} -> :gen_udp.send(socket, {127,0,0,1}, @broker_port, Poison.encode!(message))
      {:error, _reason} -> send_to_broker(sensor_data)
    end
  end

end
