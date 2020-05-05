defmodule SubscriptionsRegistry do
  use Agent


  def start_link(initial_registry) do
    Agent.start_link(fn -> initial_registry end, name: __MODULE__)
  end


  def state do
    Agent.get(__MODULE__, & &1)
  end


  def update(new_registry) do
    Agent.update(__MODULE__, &(&1 = new_registry))
  end

end
