defmodule Todo.Database.Client do
  def store(key, data) do
    :poolboy.transaction(Todo.Database.Server, fn worker_pid ->
      GenServer.call(worker_pid, {:store, key, data})
    end)
  end

  def get(key) do
    :poolboy.transaction(Todo.Database.Server, fn worker_pid ->
      GenServer.call(worker_pid, {:get, key})
    end)
  end
end
