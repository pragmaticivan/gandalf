defmodule Gandalf.AuthStrategyHelper do
  @moduledoc """
  Gandalf helper to check authentications with scopes and returns resouce
  owner.
  """

  alias Gandalf.AuthStrategy.Session, as: SessionAuthStrategy
  alias Gandalf.AuthStrategy.QueryParam, as: QueryParamAuthStrategy
  alias Gandalf.AuthStrategy.Header, as: HeaderAuthStrategy

  @doc """
  Authenticate user by using configured authorization methods and scopes.
  ## Examples
      required_scopes = ~w(read write)
      result = Gandalf.Plug.Authentication.authorize_for_resource(conn,
        required_scopes)
      case result do
        {:error, errors, _} -> IO.inspect(errors)
        nil -> IO.puts("not authencated!")
        {:ok, current_user} -> IO.puts(current_user.email)
      end
  """
  def authorize_for_resource(conn, scopes) do
    SessionAuthStrategy.authenticate(conn, scopes) ||
      QueryParamAuthStrategy.authenticate(conn, scopes) ||
      HeaderAuthStrategy.authenticate(conn, scopes)
  end
end
