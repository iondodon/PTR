defmodule WeatherInterface do

  def start_station() do
    Supervisor.start_link([ {EventsHandler, nil} ], strategy: :one_for_one)
  end

  def show_weather() do
    ForecastStation.state()
  end

end
