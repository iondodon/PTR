defmodule MessageQueue do
  use Agent


  def start_link(initial_queue) do
    Agent.start_link(fn -> initial_queue end, name: __MODULE__)
  end


  def state do
    Agent.get(__MODULE__, & &1)
  end


  def update(new_queue) do
    Agent.update(__MODULE__, &(&1 = new_queue))
  end

end
