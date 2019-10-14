defmodule Todo.Database.Server do
  @db_folder "./persist"
  @pool_size 3

  def child_spec(_) do
    Todo.Database.init(@db_folder)

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
