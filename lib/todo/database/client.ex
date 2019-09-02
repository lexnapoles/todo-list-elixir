defmodule Todo.Database.Client do
  def start do
    Todo.Database.Server.start()
  end

  def store(key, data) do
    GenServer.cast(Todo.Database.Server, {:store, key, data})
  end

  def get(key) do
    GenServer.call(Todo.Database.Server, {:get, key})
  end
end
