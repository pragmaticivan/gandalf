defmodule Gandalf.Utils.StringTest do
  use ExUnit.Case
  use Gandalf.DB.Test.DataCase
  import Gandalf.Utils.String

  test "split a string with comma" do
    str = "a, b, c   , d"
    assert comma_split(str) == ["a", "b", "c", "d"]
  end
end
