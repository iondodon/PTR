defmodule ActorModel do

  def main do
    System.cmd(
      "curl", ["--silent", "http://localhost:4000/iot"],
      into:  IO.stream(:stdio, :line)
    )
  end

end


IO.puts(ActorModel.main)