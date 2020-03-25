defmodule StateManager do
  use Task

  def start_link(new_state) do
    Task.start_link(__MODULE__, :run, [new_state])
  end

  def run(new_state) do
    ForecastStation.update(new_state)
  end
end