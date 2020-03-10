defmodule ActorModel do

  def main do
    {initial_acc, collector_fun} = Collectable.into(Collector.new())

    System.cmd(
      "curl", ["--silent", "http://localhost:4000/iot"],
      into: initial_acc
    )
  end

end

defmodule Collector do
  # for protocols
  defstruct []

  def new, do: %__MODULE__{}
end

defimpl Collectable, for: Collector do
  def into(original) do
    collector_fun = fn
      set, {:cont, elem} -> IO.puts(elem)
      set, :done -> set
      _set, :halt -> :ok
    end

    {original, collector_fun}
  end
end

IO.puts(ActorModel.main)