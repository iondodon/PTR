defmodule RemoteListener do
  use Application

  def start(_type, _args) do
    # first, it is needed to start the station
    children = [{EventListener, nil}]
    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
