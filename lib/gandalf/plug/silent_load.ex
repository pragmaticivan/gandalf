defmodule Gandalf.Plug.SilentLoad do
  @moduledoc """
  Gandalf plug implementation to load user if it's available not blocking route in case it is not.
  """

  import Plug.Conn
  alias Gandalf.AuthStrategyHelper

  def init([]), do: false

  @doc """
  Plug function to refute authencated users to access resources.
  ## Examples
      defmodule MyModule.AppController do
        use MyModule.Web, :controller
        plug Gandalf.Plug.SilentLoad when action in [:gallery]
        def gallery(conn, _params) do
          # loads the user if that is available
        end
      end
  """
  def call(conn, _opts) do
    response_conn_with(conn, AuthStrategyHelper.authorize_for_resource(conn, []))
  end

  defp response_conn_with(conn, nil), do: conn
  defp response_conn_with(conn, {:error, _, _}), do: conn
  defp response_conn_with(conn, {:ok, current_user}), do: assign(conn,
    :current_user, current_user)
end
