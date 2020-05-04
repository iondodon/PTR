defmodule StateManager do
  use Task

  def start_link(sensors) do
    Task.start_link(__MODULE__, :run, [sensors])
  end

  def run(sensors) do
    old_state = ForecastStation.state()

    if Map.has_key?(sensors, "wind_speed_sensor_1") and
         Map.has_key?(sensors, "atmo_pressure_sensor_1") do
      atmo_pressure = (sensors["atmo_pressure_sensor_1"] + sensors["atmo_pressure_sensor_2"]) / 2
      wind_speed = (sensors["wind_speed_sensor_1"] + sensors["wind_speed_sensor_2"]) / 2
      timestamp_atmo_wind = sensors["unix_timestamp_100us"]

      new_state = %{old_state |
        :atmo_pressure => atmo_pressure,
        :wind_speed => wind_speed,
        :updated_at => timestamp_atmo_wind
      }
      ForecastStation.update(new_state)

      # TODO: to fix this
      case :gen_udp.open(2053) do
        {:ok, socket} -> :gen_udp.send(socket, {127,0,0,1}, 2052, new_state)
        {:error, _reason} -> nil
      end
    end

    if Map.has_key?(sensors, "light_sensor_1") do
      light = (sensors["light_sensor_1"] + sensors["light_sensor_2"]) / 2
      timestamp_light = sensors["unix_timestamp_100us"]

      new_state = %{old_state | :light => light, :updated_at => timestamp_light}
      ForecastStation.update(new_state)

      # TODO: to fix this
      case :gen_udp.open(2053) do
        {:ok, socket} -> :gen_udp.send(socket, {127,0,0,1}, 2052, "hello0")
        {:error, _reason} -> nil
      end
    end

    if Map.has_key?(sensors, "SensorReadings") do
      content = sensors["SensorReadings"]["#content"]

      [humidity_percent0, humidity_percent1] = content["humidity_percent"]["value"]
      [temperature_celsius0, temperature_celsius1] = content["temperature_celsius"]["value"]
      timestamp_hum_temp = sensors["SensorReadings"]["-unix_timestamp_100us"]

      {humidity_percent0, _} = Float.parse(humidity_percent0)
      {humidity_percent1, _} = Float.parse(humidity_percent1)
      {temperature_celsius0, _} = Float.parse(temperature_celsius0)
      {temperature_celsius1, _} = Float.parse(temperature_celsius1)
      {timestamp_hum_temp, _} = Integer.parse(timestamp_hum_temp)

      humidity = (humidity_percent0 + humidity_percent1) / 2
      temperature = (temperature_celsius0 + temperature_celsius0) / 2

      new_state = %{old_state |
        :humidity => humidity,
        :temperature => temperature,
        :updated_at => timestamp_hum_temp
      }
      ForecastStation.update(new_state)

      # TODO: to fix this
      case :gen_udp.open(2053) do
        {:ok, socket} -> :gen_udp.send(socket, {127,0,0,1}, 2052, "hello1")
        {:error, _reason} -> nil
      end
    end

    update_weather_description
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
