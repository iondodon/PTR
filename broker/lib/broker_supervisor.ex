defmodule BrokerSupervisor do
  use Supervisor

  def start_link do
    IO.inspect("Started")
    Supervisor.start_link(__MODULE__, [])
  end


  def init(_) do
    children = [
      worker(Broker, [])
    ]

    supervise(children, strategy: :one_for_all)
  end
end