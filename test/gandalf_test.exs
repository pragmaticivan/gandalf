defmodule GandalfTest do
  use ExUnit.Case
  doctest Gandalf

  test "greets the world" do
    assert Gandalf.hello() == :world
  end
end
