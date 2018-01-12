defmodule Gandalf.Authentication.Basic do
  @moduledoc """
  Basic authentication helper module, implements Gandalf.Authentication
  behaviour.
  """

  alias Gandalf.Utils.Crypt, as: CryptUtil

  @behaviour Gandalf.Authentication
  @repo Application.get_env(:gandalf, :repo)
  @resource_owner Application.get_env(:gandalf, :resource_owner)

  @doc """
  Authenticates resource-owner using Basic Authentication header value.
  It handles the decoding the 'Authorization: Basic {auth_credentials}'
  and matches resource owner with given email and password. Since Basic auth
  requires identity and password, it does not require any scope check for
  authorization.
  If any resource owner matched given credentials,
  it returns `{:ok, Gandalf.User.Model struct}`, otherwise
  `{:error, Map, :http_status_code}`
  ## Examples
      # Suppose we have a resource owner with
      # email: foo@example.com and password: 12345678.
      # Base 64 encoding of email:password combination will be
      # 'Zm9vQGV4YW1wbGUuY29tOjEyMzQ1Njc4'. If we pass the encoded value
      # to the function, it will return resource-owner
      Gandalf.Authentication.Basic.authenticate(
        "Zm9vQGV4YW1wbGUuY29tOjEyMzQ1Njc4", [])
      Gandalf.Authentication.Basic.authenticate(
        "Basic Zm9vQGV4YW1wbGUuY29tOjEyMzQ1Njc4", [])
  """
  def authenticate(auth_credentials, _required_scopes),
    do: authenticate_with_credentials(auth_credentials)

  defp authenticate_with_credentials("Basic " <> auth_credentials), do:
    authenticate_with_credentials(auth_credentials)
  defp authenticate_with_credentials(auth_credentials) do
    case Base.decode64(auth_credentials) do
      {:ok, credentials} ->
        [email, password] = String.split(credentials, ":")
        authenticate_with_credentials(email, password)
      :error -> {:error, %{invalid_request: "Invalid credentials encoding.",
        headers: error_headers()},
        :bad_request}
    end
  end
  defp authenticate_with_credentials(email, password) do
    case @repo.get_by(@resource_owner, email: email) do
      nil ->
        {:error, %{invalid_credentials: "Identity not found.", headers:
          error_headers()}, :unauthorized}
      user ->
        case match_with_user_password(password, user) do
          true -> {:ok, user}
          false -> {:error, %{invalid_credentials:
            "Identity, password combination is wrong.",
            headers: error_headers()}, :unauthorized}
        end
    end
  end

  defp match_with_user_password(password, user),
    do: CryptUtil.match_password(password, Map.get(user, :password, ""))

  defp error_headers,
    do: [%{"www-authenticate" => "Basic realm=\"gandalf\""}]
end
