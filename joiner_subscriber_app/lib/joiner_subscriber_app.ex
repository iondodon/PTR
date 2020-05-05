defmodule JoinerSubscriberApp do
  use Application


  def start(_type, _args) do
    BaseSupervisor.start_link()
  end
end