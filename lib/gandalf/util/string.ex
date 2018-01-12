defmodule Gandalf.Utils.String do
  @moduledoc """
  String utilities
  """

  @doc """
  Trim a string and then split using comma
  """
  def comma_split(str), do: trim_split(str, ",")

  defp trim_split(str, char) do
    str
    |> String.replace(~r/([\s]+)/, "")
    |> String.split(char, trim: true)
  end
end
