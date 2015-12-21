defmodule Riboflavin.B2Auth do
  def start_link do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def update(key, data) do
    Agent.update(__MODULE__, &Map.put(&1, key, data))
  end

  def get(key) do
    Agent.get(__MODULE__, &Map.get(&1, key))
  end
end
