defmodule Gandalf.Utils.List do
  @moduledoc """
  List utilities
  """

  @doc """
  Check if a list superset of given list
  """
  def subset?(super_list, list) do
    list
    |> Enum.find(fn item -> !Enum.member?(super_list, item) end)
    |> is_nil
  end
end
