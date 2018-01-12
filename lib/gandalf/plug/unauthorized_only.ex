defmodule Gandalf.Plug.UnauthorizedOnly do
  @moduledoc """
  Gandalf plug implementation to refute authencated users to access resources.
  """

  import Plug.Conn
  alias Gandalf.AuthStrategyHelper

  @renderer Application.get_env(:gandalf, :renderer)

  def init([]), do: false

  @doc """
  Plug function to refute authencated users to access resources.
  ## Examples
      defmodule MyModule.AppController do
        use MyModule.Web, :controller
        plug Gandalf.Plug.UnauthorizedOnly when action in [:register]
        def register(conn, _params) do
          # only not logged in user can access this action
        end
      end
  """
  def call(conn, _opts) do
    response_conn_with(conn, AuthStrategyHelper.authorize_for_resource(conn, []))
  end

  defp response_conn_with(conn, nil), do: conn
  defp response_conn_with(conn, {:error, _, _}), do: conn
  defp response_conn_with(conn, _) do
    conn
    |> @renderer.render(:bad_request, %{errors: %{details: "Only unauhorized access allowed!"}})
    |> halt
  end
end
