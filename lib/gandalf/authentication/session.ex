defmodule Gandalf.Authentication.Session do
  @moduledoc """
  Bearer authencation helper module, implements Gandalf.Authentication
  behaviour.
  """

  alias Gandalf.Authentication.Token, as: TokenAuthentication

  @behaviour Gandalf.Authentication

  @doc """
  Authenticates resource-owner using session_token token value.
  It matches resource owner with given session_token. Since Session auth
  represents resource owners direct access to resources, it does not require
  any scope check for authorization.
  If any resource owner matched given credentials,
  it returns `{:ok, Gandalf.Model.User struct}`, otherwise
  `{:error, Map, :http_status_code}`
  ## Examples
      # Suppose we have a session_token at 'token store(Gandalf.Token)'
      # with token value "st123456789"
      # If we pass the token value to the function,
      # it will return resource-owner.
      Gandalf.Authentication.Session.authenticate("st123456789", [])
  """
  def authenticate(session_token, required_scopes) do
    case TokenAuthentication.authenticate({"session_token", session_token}, required_scopes) do
      {:ok, user} -> {:ok, user}
      {:error, errors, status} -> {:error, Map.put(errors, :headers, error_headers()), status}
    end
  end

  defp error_headers, do: [%{"www-authenticate" => "Cookie realm=\"gandalf\""}]
end
