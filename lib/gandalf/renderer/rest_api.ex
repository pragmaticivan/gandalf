
defmodule Gandalf.Renderer.RestApi do
  @moduledoc """
  An implementation for `Gandalf.Rederer` to render Gandalf errors in RestAPI
  format.
  """

  import Plug.Conn

  @behaviour Gandalf.Renderer

  def render(conn, status, map) do
    conn
    |> put_resp_content_type("application/json", "utf-8")
    |> resp(status, Poison.encode!(merge_error_keys(map)))
  end

  defp merge_error_keys(%{errors: errors}) do
    %{errors: Enum.reduce(errors, %{}, fn({key, val}, acc) ->
      Map.update(acc, key, [val], &[val|&1])
    end)}
  end
  defp merge_error_keys(map), do: map
end
