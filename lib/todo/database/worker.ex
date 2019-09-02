defmodule Todo.Database.Worker do
  use GenServer

  def start(db_folder) do
    GenServer.start(__MODULE__, db_folder)
  end

  @impl GenServer
  def init(db_folder) do
    Todo.Database.init(db_folder)

    {:ok, db_folder}
  end

  @impl GenServer
  def handle_cast({:store, key, data}, db_folder) do
    Todo.Database.store(db_folder, key, data)

    {:noreply, db_folder}
  end

  @impl GenServer
  def handle_call({:get, key}, _, db_folder) do
    data = Todo.Database.get(db_folder, key)

    {:reply, data, db_folder}
  end
end
