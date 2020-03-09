defmodule ActorModel do

  def main do
    System.cmd(
      "curl", ["--silent", "http://localhost:4000/iot"],
      into:  Collectable.into(MapSet.new())
    )
  end

end

defimpl Collectable, for: MapSet do
  def into(original) do
    collector_fun = fn
      set, {:cont, elem} -> MapSet.put(set, elem)
      set, :done -> set
      _set, :halt -> :ok
    end

    {original, collector_fun}
  end
end

IO.puts(ActorModel.main)