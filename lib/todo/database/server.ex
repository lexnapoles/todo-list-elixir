defmodule Todo.Database.Server do
  @db_folder "./persist"
  @pool_size 3

  def start_link do
    IO.puts("Starting database")

    Todo.Database.init(@db_folder)

    1..@pool_size
    |> Enum.map(&worker_spec/1)
    |> Supervisor.start_link(strategy: :one_for_one)
  end

  defp worker_spec(worker_id) do
    default_worker_spec = {Todo.Database.Worker, {@db_folder, worker_id}}
    Supervisor.child_spec(default_worker_spec, id: worker_id)
  end

  def child_spec(_) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      type: :supervisor
    }
  end

  def choose_worker(key) do
    worker = :erlang.phash2(key, @pool_size) + 1

    worker |> Todo.Database.Worker.via_tuple()
  end
end
