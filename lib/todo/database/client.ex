defmodule Todo.Database.Client do
  def store(key, data) do
    key
    |> Todo.Database.Server.choose_worker()
    |> GenServer.cast({:store, key, data})
  end

  def get(key) do
    key
    |> Todo.Database.Server.choose_worker()
    |> GenServer.call({:get, key})
  end
end
