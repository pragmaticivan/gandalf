defmodule Gandalf.Plug.Authentication do
  @moduledoc """
  Gandalf plug implementation
  """

  import Plug.Conn
  alias Gandalf.AuthStrategyHelper

  @renderer Application.get_env(:gandalf, :renderer)

  def init(opts) do
    Keyword.get(opts, :scopes, "")
  end

  @doc """
  Plug function to authenticate client for resouce owner and assigns resource
  owner into conn.assigns[:current_user] key.

  If it fails, then it halts connection and returns :bad_request, :unauthorized
  or :forbidden status codes with error json.

  There is one option:
    * scopes - the function used to authorize the resource access
    * the default is ""
  ## Examples
      defmodule MyModule.AppController do
        use MyModule.Web, :controller
        plug Gandalf.Plug.Authentication, [scopes: ~w(read write)]
        def index(conn, _params) do
          # access to current user on successful authentication
          current_user = conn.assigns[:current_user]
          ...
        end
      end
      defmodule MyModule.AppController do
        use SomeModule.Web, :controller
        plug Gandalf.Plug.Authentication [scopes: ~w(read write)] when action in [:show]
        def index(conn, _params) do
          # anybody can call this action
          ...
        end
        def show(conn, _params) do
          # only logged in users can access this action
          current_user = conn.assigns[:current_user]
          ...
        end
      end
  """
  def call(conn, scopes) do
    response_conn_with(conn, AuthStrategyHelper.authorize_for_resource(conn, scopes))
  end

  defp response_conn_with(conn, nil) do
    conn
    |> put_resp_header("www-authenticate", "Bearer realm=\"gandalf\"")
    |> @renderer.render(:forbidden, %{
         errors: %{details: "Resource access requires authentication!"}
       })
    |> halt
  end

  defp response_conn_with(conn, {:error, errors, http_status_code}) do
    [%{"www-authenticate" => header_val}] = errors[:headers]
    errors = %{errors: Map.delete(errors, :headers)}

    conn
    |> put_resp_header("www-authenticate", header_val)
    |> @renderer.render(http_status_code, %{errors: errors})
    |> halt
  end

  defp response_conn_with(conn, {:ok, current_user}),
    do: assign(conn, :current_user, current_user)
end
