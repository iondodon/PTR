defmodule BrokerSupervisor do
  use Supervisor
  @broker_port 2052

  def start_link do
    Supervisor.start_link(__MODULE__, [])
  end


  def init(_) do
    children = [
      worker(Broker, [@broker_port])
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end