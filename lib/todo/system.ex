defmodule Todo.System do
  def start_link do
    Supervisor.start_link(
      [Todo.Metrics, Todo.Database.Server, Todo.Cache, Todo.Web],
      strategy: :one_for_one
    )
  end
end
