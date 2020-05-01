defmodule StateManager do
  use Task

  def start_link(new_state) do
    Task.start_link(__MODULE__, :run, [new_state])
  end

  def run(new_state) do
    if new_state != nil do

      sensors = new_state["message"]

      atmo_pressure = (sensors["atmo_pressure_sensor_1"] + sensors["atmo_pressure_sensor_2"]) / 2
      humidity = (sensors["humidity_sensor_1"] + sensors["humidity_sensor_2"]) / 2
      light = (sensors["light_sensor_1"] + sensors["light_sensor_2"]) / 2
      temperature = (sensors["temperature_sensor_1"] + sensors["temperature_sensor_2"]) / 2
      wind_speed = (sensors["wind_speed_sensor_1"] + sensors["wind_speed_sensor_2"]) / 2
      timestamp = sensors["unix_timestamp_us"]

      weather = fn ->
        cond do
          temperature < -2 and light < 128 and atmo_pressure < 720 -> "SNOW"
          temperature < -2 and light > 128 and atmo_pressure < 680 -> "WET_SNOW"
          temperature < -8 -> "SNOW"
          temperature < -15 and wind_speed > 45 -> "BLIZZARD"
          temperature > 0 and atmo_pressure < 710 and humidity > 70 and wind_speed < 20 -> "SLIGHT_RAIN"
          temperature > 0 and atmo_pressure < 690 and humidity > 70 and wind_speed > 20 -> "HEAVY_RAIN"
          temperature > 30 and atmo_pressure < 770 and humidity > 80 and light > 192 -> "HOT"
          temperature > 30 and atmo_pressure < 770 and humidity > 50 and light > 192 and wind_speed > 35 -> "CONVECTION_OVEN"
          temperature > 25 and atmo_pressure < 750 and humidity > 70 and light < 192 and wind_speed < 10 -> "WARM"
          temperature > 25 and atmo_pressure < 750 and humidity > 70 and light < 192 and wind_speed > 10 -> "SLIGHT_BREEZE"
          light < 128 -> "CLOUDY"
          temperature > 30 and atmo_pressure < 660 and humidity > 85 and wind_speed > 45 -> "MONSOON"
          true -> "JUST_A_NORMAL_DAY"
        end
      end

      old_state = ForecastStation.state()
      # update at each 5 seconds
      if old_state[:updated_at] == nil or timestamp - old_state[:updated_at] > 5000000 do
        ForecastStation.update(%{:updated_at => sensors["unix_timestamp_us"], :weather => weather.()})
      end
    end

  end
end