defmodule Todo.System do
  def start_link do
    Supervisor.start_link([Todo.Metrics, Todo.ProcessRegistry, Todo.Database.Server, Todo.Cache],
      strategy: :one_for_one
    )
  end
end
