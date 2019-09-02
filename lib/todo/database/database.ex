defmodule Todo.Database do
  def init(db_folder) do
    File.mkdir_p!(db_folder)
  end

  def store(db_folder, key, data) do
    db_folder
    |> file_name(key)
    |> File.write!(:erlang.term_to_binary(data))
  end

  def get(db_folder, key) do
    data =
      case File.read(file_name(db_folder, key)) do
        {:ok, contents} -> :erlang.binary_to_term(contents)
        _ -> nil
      end

    data
  end

  def file_name(db_folder, key) do
    path = Path.join(db_folder, to_string(key))
    IO.puts("folder #{db_folder} key #{key}, path #{path}")

    path
  end
end
