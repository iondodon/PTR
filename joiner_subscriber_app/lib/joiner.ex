defmodule Joiner do



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