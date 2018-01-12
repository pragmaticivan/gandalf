defmodule Gandalf.AuthStrategy.Header do
  @moduledoc """
  Gandalf Strategy implements behaviour Gandalf.Strategy to check 'header'
  based authentications to find resource owner.
  """

  import Plug.Conn, only: [get_req_header: 2]

  @behaviour Gandalf.AuthStrategy
  @auth_strategies Application.get_env(:gandalf, :auth_strategies)
  @header_auth Map.get(@auth_strategies, :headers)

  @doc """
  Finds resource owner using configured 'headers' keys. Returns nil if
  either no keys are configured or key value not found in the session.
  And, it returns `Gandalf.Model.User` on sucess,
  `{:error, Map, :http_status_code}` on fails.
  """
  def authenticate(conn, required_scopes) do
    unless is_nil(@header_auth) do
      authenticate(conn, @header_auth, required_scopes)
    end
  end

  defp authenticate(conn, header_auth, required_scopes) do
    Enum.find_value(header_auth, fn {key, authentications} ->
      case List.first(get_req_header(conn, key)) do
        nil -> nil
        header_val -> authenticate_via_header(authentications, header_val, required_scopes)
      end
    end)
  end

  defp authenticate_via_header(authentications, header_val, required_scopes) do
    Enum.find_value(authentications, fn tuple ->
      authenticate_via_header_val(tuple, header_val, required_scopes)
    end)
  end

  defp authenticate_via_header_val({pattern, module}, header_val, required_scopes) do
    if Regex.match?(pattern, header_val) do
      module.authenticate(header_val, required_scopes)
    end
  end
end
