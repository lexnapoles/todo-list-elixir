defmodule Todo.Server do
  use GenServer, restart: :temporary

  @expiry_idle_timeout :timer.seconds(10)

  def start_link(name) do
    GenServer.start_link(__MODULE__, name, name: global_name(name))
  end

  @impl GenServer
  def init(name) do
    IO.inspect(name)
    IO.puts("Starting to-do server for #{name}")
    send(self(), {:real_init, name})
    {:ok, nil}
  end

  @impl GenServer
  def handle_call({:entries, date}, _, {_name, todo_list} = state) do
    entries = Todo.List.entries(todo_list, date)

    {:reply, entries, state, @expiry_idle_timeout}
  end

  @impl GenServer
  def handle_cast({:add_entry, new_entry}, {name, todo_list}) do
    new_list = Todo.List.add_entry(todo_list, new_entry)

    Todo.Database.Client.store(name, new_list)

    {:noreply, {name, new_list}, @expiry_idle_timeout}
  end

  @impl GenServer
  def handle_cast({:update_entries, new_entry}, {name, todo_list}) do
    new_list = Todo.List.update_entry(todo_list, new_entry)

    Todo.Database.Client.store(name, new_list)

    {:noreply, {name, new_list}}
  end

  @impl GenServer
  def handle_cast({:update_entries, entry_id, updater_fun}, {name, todo_list}) do
    new_list = Todo.List.update_entry(todo_list, entry_id, updater_fun)

    Todo.Database.Client.store(name, new_list)

    {:noreply, {name, new_list}}
  end

  @impl GenServer
  def handle_cast({:delete_entry, entry_id}, {name, todo_list}) do
    new_list = Todo.List.delete_entry(todo_list, entry_id)

    Todo.Database.Client.store(name, new_list)

    {:noreply, {name, new_list}}
  end

  @impl GenServer
  def handle_info({:real_init, name}, _state) do
    IO.puts("Starting to-do server real init")

    {:noreply, {name, Todo.Database.Client.get(name) || Todo.List.new()}, @expiry_idle_timeout}
  end

  def handle_info(:timeout, {name, todo_list}) do
    IO.puts("Stopping to-do server for #{name}")
    {:stop, :normal, {name, todo_list}}
  end

  defp global_name(name) do
    {:global, {__MODULE__, name}}
  end

  def whereis(name) do
    case :global.whereis_name({__MODULE__, name}) do
      :undefined -> nil
      pid -> pid
    end
  end
end
