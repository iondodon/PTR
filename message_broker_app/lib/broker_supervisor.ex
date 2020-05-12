defmodule BrokerSupervisor do
  use Supervisor
  @broker_port 2052


  def start_link do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end


  def init(_) do
    children = [
      worker(MessageListener, [@broker_port]),
      worker(MessageQueue, [:queue.new()]),
      worker(SubscriptionsRegistry, [[]]),
      worker(Spreader, [])
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end

end
