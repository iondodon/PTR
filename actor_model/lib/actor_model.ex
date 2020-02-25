defmodule ActorModel do

  def main do
    {:ok, pid} = EventsourceEx.new("https://localhost:4000", stream_to: self)
  end
end

IO.puts(ActorModel.main())