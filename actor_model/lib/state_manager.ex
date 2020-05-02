defmodule StateManager do
  use Task

  def start_link(sensors) do
    Task.start_link(__MODULE__, :run, [sensors])
  end

  def run(sensors) do
    old_state = ForecastStation.state()

    if Map.has_key?(sensors, "wind_speed_sensor_1") and Map.has_key?(sensors, "atmo_pressure_sensor_1") do
      atmo_pressure = (sensors["atmo_pressure_sensor_1"] + sensors["atmo_pressure_sensor_2"]) / 2
      wind_speed = (sensors["wind_speed_sensor_1"] + sensors["wind_speed_sensor_2"]) / 2
      timestamp_atmo_wind = sensors["unix_timestamp_100us"]
      ForecastStation.update(%{
        old_state | :atmo_pressure => atmo_pressure, :wind_speed => wind_speed, :timestamp_atmo_wind => timestamp_atmo_wind
      })
    end

    if Map.has_key?(sensors, "light_sensor_1") do
      light = (sensors["light_sensor_1"] + sensors["light_sensor_2"]) / 2
      timestamp_light = sensors["unix_timestamp_100us"]
      ForecastStation.update(%{ old_state | :light => light, :timestamp_light => timestamp_light })
    end

#    if Map.has_key?(sensors, "humidity_percent") and Map.has_key?(sensors, "temperature_celsius") do
#      humidity = (sensors["humidity_percent"] + sensors["humidity_percent"]) / 2
#      temperature = (sensors["temperature_celsius"] + sensors["temperature_celsius"]) / 2
#      timestamp_hum_temp = sensors["unix_timestamp_100us"]
#      ForecastStation.update(%{
#        old_state | :humidity => humidity, :temperature => temperature, :timestamp_hum_temp => timestamp_hum_temp
#      })
#    end

#    weather = fn ->
#      cond do
#        temperature < -2 and light < 128 and atmo_pressure < 720 -> "SNOW"
#        temperature < -2 and light > 128 and atmo_pressure < 680 -> "WET_SNOW"
#        temperature < -8 -> "SNOW"
#        temperature < -15 and wind_speed > 45 -> "BLIZZARD"
#        temperature > 0 and atmo_pressure < 710 and humidity > 70 and wind_speed < 20 -> "SLIGHT_RAIN"
#        temperature > 0 and atmo_pressure < 690 and humidity > 70 and wind_speed > 20 -> "HEAVY_RAIN"
#        temperature > 30 and atmo_pressure < 770 and humidity > 80 and light > 192 -> "HOT"
#        temperature > 30 and atmo_pressure < 770 and humidity > 50 and light > 192 and wind_speed > 35 -> "CONVECTION_OVEN"
#        temperature > 25 and atmo_pressure < 750 and humidity > 70 and light < 192 and wind_speed < 10 -> "WARM"
#        temperature > 25 and atmo_pressure < 750 and humidity > 70 and light < 192 and wind_speed > 10 -> "SLIGHT_BREEZE"
#        light < 128 -> "CLOUDY"
#        temperature > 30 and atmo_pressure < 660 and humidity > 85 and wind_speed > 45 -> "MONSOON"
#        true -> "JUST_A_NORMAL_DAY"
#      end
#    end

  end
end