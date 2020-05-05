defmodule BaseSupervisor do
  use Supervisor

  @joiner_subscriber_port 2054


  def start_link do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end


  def init(_) do
    children = [
      worker(ForecastStation,
        [%{
          "atmo_pressure" => nil,
          "wind_speed" => nil,
          "light" => nil,
          "humidity" => nil,
          "temperature" => nil,
          "timestamp_atmo_wind" => nil,
          "timestamp_light" => nil,
          "timestamp_hum_temp" => nil
        }]),
      worker(BrokerListener, []),
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end

end