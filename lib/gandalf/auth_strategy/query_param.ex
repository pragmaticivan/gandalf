defmodule Gandalf.AuthStrategy.QueryParam do
  @moduledoc """
  Gandalf Strategy implements behaviour Gandalf.Strategy to check query params
  based authencations to find resource owner.
  """

  @behaviour Gandalf.AuthStrategy
  @auth_strategies Application.get_env(:gandalf, :auth_strategies)
  @query_params_auth Map.get(@auth_strategies, :query_params)

  @doc """
  Finds resource owner using configured 'query params' keys. Returns nil if
  either no keys are configured or key value not found in the session.
  And, it returns `Gandalf.Model.User` on sucess,
  `{:error, Map, :http_status_code}` on fails.
  """
  def authenticate(conn, required_scopes) do
    unless is_nil(@query_params_auth) do
      authenticate_via_query_params(@query_params_auth, conn.query_params, required_scopes)
    end
  end

  def authenticate(conn) do
    unless is_nil(@query_params_auth) do
      authenticate_via_query_params(@query_params_auth, conn.query_params, [])
    end
  end

  defp authenticate_via_query_params(query_params_auth, params, required_scopes) do
    Enum.find_value(query_params_auth, fn {key, module} ->
      if Map.has_key?(params, key) do
        module.authenticate(params, required_scopes)
      end
    end)
  end
end
