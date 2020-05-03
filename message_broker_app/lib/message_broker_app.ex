defmodule MessageBrokerApp do
  use Application

  def start(_type, _args) do
    BrokerSupervisor.start_link()
  end
end
