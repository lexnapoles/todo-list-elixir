defmodule Todo.Database.Server do
  use GenServer
  @db_folder "./persist"
  @workers 3

  def start do
    GenServer.start(__MODULE__, nil, name: __MODULE__)
  end

  @impl GenServer
  def init(_) do
    workers =
      1..@workers
      |> Stream.map(fn _ ->
        {:ok, pid} = Todo.Database.Worker.start(@db_folder)
        pid
      end)
      |> Stream.with_index()
      |> Map.new(fn {pid, index} -> {index, pid} end)

    {:ok, workers}
  end

  @impl GenServer
  def handle_cast({:store, key, _data} = msg, state) do
    worker = choose_worker(state, key)

    GenServer.cast(worker, msg)

    {:noreply, state}
  end

  @impl GenServer
  def handle_call({:get, key} = msg, _, state) do
    worker = choose_worker(state, key)

    data = GenServer.call(worker, msg)

    {:reply, data, state}
  end

  defp choose_worker(workers, key) do
    workers
    |> Map.get(:erlang.phash2(key, @workers))
  end
end
