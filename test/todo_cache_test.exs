defmodule TodoCacheTest do
  use ExUnit.Case
  doctest Todo.Cache

  test "server_process" do
    bob_pid = Todo.Cache.server_process("bob")

    assert bob_pid != Todo.Cache.server_process("alice")
    assert bob_pid == Todo.Cache.server_process("bob")
  end
end
