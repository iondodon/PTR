defmodule ForecastStation do
  use Agent


  def start_link(initial_state) do
    Agent.start_link(fn -> initial_state end, name: __MODULE__)
  end


  def state do
    Agent.get(__MODULE__, & &1)
  end


  def update(new_state) do
    Agent.update(__MODULE__, &(&1 = new_state))
  end

end
