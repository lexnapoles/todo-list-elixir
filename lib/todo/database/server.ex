defmodule Todo.Database.Server do
  @pool_size 3
  @db_folder "./persist"

  def child_spec(_) do
    :poolboy.child_spec(
      __MODULE__,
      [
        __MODULE__,
        name: {:local, __MODULE__},
        worker_module: Todo.Database.Worker,
        size: @pool_size
      ],
      [{@db_folder}]
    )
  end
end
