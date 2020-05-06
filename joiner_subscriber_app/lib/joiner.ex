defmodule Joiner do
  @window 1000

  def show_state do
    ForecastStation.state()
  end


  def join(new_sensors_data) do
    sensors = ForecastStation.state()

    if sensors["timestamp"] == nil
       or abs(new_sensors_data["timestamp"] - sensors["timestamp"]) < @window do
      new_state = Map.merge(sensors, new_sensors_data)
      ForecastStation.update(new_state)
      :done
    end

    sensors_state = ForecastStation.state()
    weather_description = weather_description(sensors_state)
    ForecastStation.update(%{sensors_state | "weather_description" => weather_description})
  end


  def weather_description(sensors_state) do
    %{
      "atmo_pressure" => atmo_pressure,
      "wind_speed" => wind_speed,
      "light" => light,
      "humidity" => humidity,
      "temperature" => temperature,
      "timestamp" => timestamp,
      "weather_description" => weather_description
    } = sensors_state

    cond do
      temperature < -2 and light < 128 and atmo_pressure < 720 ->
        "SNOW"

      temperature < -2 and light > 128 and atmo_pressure < 680 ->
        "WET_SNOW"

      temperature < -8 ->
        "SNOW"

      temperature < -15 and wind_speed > 45 ->
        "BLIZZARD"

      temperature > 0 and atmo_pressure < 710 and humidity > 70 and
      wind_speed < 20 ->
        "SLIGHT_RAIN"

      temperature > 0 and atmo_pressure < 690 and humidity > 70 and
      wind_speed > 20 ->
        "HEAVY_RAIN"

      temperature > 30 and atmo_pressure < 770 and humidity > 80 and
      light > 192 ->
        "HOT"

      temperature > 30 and atmo_pressure < 770 and humidity > 50 and
      light > 192 and wind_speed > 35 ->
        "CONVECTION_OVEN"

      temperature > 25 and atmo_pressure < 750 and humidity > 70 and
      light < 192 and wind_speed < 10 ->
        "WARM"

      temperature > 25 and atmo_pressure < 750 and humidity > 70 and
      light < 192 and wind_speed > 10 ->
        "SLIGHT_BREEZE"

      light < 128 ->
        "CLOUDY"

      temperature > 30 and atmo_pressure < 660 and humidity > 85 and
      wind_speed > 45 ->
        "MONSOON"

      true ->
        "JUST_A_NORMAL_DAY"
    end

#    ForecastStation.update(%{old_state | :description => get_description.()})
  end

end