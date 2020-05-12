# this supervisor will restart all the workers it supervises is at least one of them shuts down
# also, is start all the workers for the first time
defmodule BaseSupervisor do
  use Supervisor

  @joiner_subscriber_port 2054


  def start_link do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end


  def init(_) do
    # define the workers and their initial state, (children)
    children = [
      worker(ForecastStation,
        [%{
          "atmo_pressure" => nil,
          "wind_speed" => nil,
          "light" => nil,
          "humidity" => nil,
          "temperature" => nil,
          "timestamp" => nil,
          "weather_description" => nil
        }]),
      worker(BrokerListener, []),
    ]

    # start the workers
    Supervisor.init(children, strategy: :one_for_all)
  end

end