defmodule Todo.Database.Worker do
  use GenServer

  def start_link([{db_folder}]) do
    IO.puts("Starting database worker")
    node_folder = node_db_folder(db_folder)
    Todo.Database.init(node_folder)

    GenServer.start_link(__MODULE__, db_folder)
  end

  @impl GenServer
  def init(db_folder) do
    {:ok, db_folder}
  end

  @impl GenServer
  def handle_call({:store, key, data}, _, db_folder) do
    propagate_store(db_folder, key, data)

    {:reply, :ok, db_folder}
  end

  @impl GenServer
  def handle_call({:get, key}, _, db_folder) do
    data =
      db_folder
      |> node_db_folder
      |> Todo.Database.get(key)

    {:reply, data, db_folder}
  end

  def propagate_store(db_folder, key, data) do
    {_results, bad_nodes} =
      :rpc.multicall(__MODULE__, :store, [db_folder, key, data], :timer.seconds(5))

    Enum.each(bad_nodes, &IO.puts("Store failed on node #{&1}"))
  end

  def store(db_folder, key, data) do
    db_folder
    |> node_db_folder
    |> Todo.Database.store(key, data)
  end

  defp node_db_folder(db_folder) do
    Path.join(db_folder, "#{Node.self()}")
  end
end
