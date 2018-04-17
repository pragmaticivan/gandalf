defmodule Gandalf.GrantType.AuthorizationCode do
  @moduledoc """
  AuthorizationCode grant type for OAuth2 Authorization Server
  """

  use Gandalf.RepoBase
  import Gandalf.Config, only: [repo: 0]
  import Gandalf.GrantType.Base
  alias Gandalf.GrantType.Error, as: GrantTypeError

  @behaviour Gandalf.GrantType
  @grant_type "authorization_code"

  @doc """
  Authorize client for 'resource owner' using client credentials and
  authorization code.
  For authorization, authorize function requires a map contains 'client_id',
  'client_secret', 'redirect_uri'(must match with authorization code token's),
  and 'code' keys. With valid credentials; it automatically creates
  access_token and refresh_token(if enabled via config) then it returns
  `Gandalf.Model.Token` struct, otherwise `{:error, Map, :http_status_code}`.
  ## Examples
      # With OAuth2 optional scope
      Gandalf.GrantType.AuthorizationCode.authorize(%{
        "client_id" => "52024ca6-cf1d-4a9d-bfb6-9bc5023ad56e",
        "client_secret" => "Wi7Y_Q5LU4iIwJArgqXq2Q",
        "redirect_uri" => "http://localhost:4000/oauth2/callbacks",
        "code" => "W_hb8JEDmeYChsNfOGCmbQ",
        "scope" => "read"
      })
      # Without OAuth2 optional scope
      Gandalf.GrantType.AuthorizationCode.authorize(%{
        "client_id" => "52024ca6-cf1d-4a9d-bfb6-9bc5023ad56e",
        "client_secret" => "Wi7Y_Q5LU4iIwJArgqXq2Q",
        "redirect_uri" => "http://localhost:4000/oauth2/callbacks",
        "code" => "W_hb8JEDmeYChsNfOGCmbQ"
      })
  """
  def authorize(%{
        "client_id" => client_id,
        "client_secret" => client_secret,
        "code" => code,
        "redirect_uri" => redirect_uri,
        "scope" => scopes
      }) do
    client = repo().get_by(@client, id: client_id, secret: client_secret)
    do_authorize(client, code, redirect_uri, scopes)
  end

  def authorize(%{
        "client_id" => client_id,
        "client_secret" => client_secret,
        "code" => code,
        "redirect_uri" => redirect_uri
      }) do
    client = repo().get_by(@client, id: client_id, secret: client_secret)
    do_authorize(client, code, redirect_uri, "")
  end

  def authorize(_) do
    GrantTypeError.invalid_request("Request must include at least client_id,
      client_secret, code and redirect_uri parameters.")
  end

  defp do_authorize(nil, _, _, _),
    do: GrantTypeError.invalid_client("Invalid client id or secret.")

  defp do_authorize(client, code, redirect_uri, scopes) do
    token = repo().get_by(@token_store, value: code, name: @grant_type)
    create_tokens(token, client, redirect_uri, scopes)
  end

  defp create_tokens(nil, _, _, _),
    do: {:error, %{invalid_token: "Token not found."}, :unauthorized}

  defp create_tokens(token, client, redirect_uri, required_scopes) do
    {:ok, token}
    |> validate_client_match(client)
    |> validate_token_expiration
    |> validate_token_redirect_uri(redirect_uri)
    |> validate_token_scope(required_scopes)
    |> validate_app_authorization
    |> delete_token
    |> create_oauth2_tokens
  end

  defp create_oauth2_tokens({:error, err, code}), do: {:error, err, code}

  defp create_oauth2_tokens({:ok, token}) do
    create_oauth2_tokens(
      token.user_id,
      @grant_type,
      token.details["client_id"],
      token.details["scope"],
      token.details["redirect_uri"]
    )
  end

  defp delete_token({:error, err, code}), do: {:error, err, code}

  defp delete_token({:ok, token}) do
    repo().delete!(token)
    {:ok, token}
  end

  defp validate_app_authorization({:error, err, code}), do: {:error, err, code}

  defp validate_app_authorization({:ok, token}) do
    if app_authorized?(token.user_id, token.details["client_id"]) do
      {:ok, token}
    else
      GrantTypeError.access_denied("Resource owner revoked access for the client.")
    end
  end

  defp validate_token_scope({:error, err, code}, _), do: {:error, err, code}
  defp validate_token_scope({:ok, token}, ""), do: {:ok, token}

  defp validate_token_scope({:ok, token}, required_scopes) do
    required_scopes = required_scopes |> Gandalf.Utils.String.comma_split()
    scopes = Gandalf.Utils.String.comma_split(token.details["scope"])

    if Gandalf.Utils.List.subset?(scopes, required_scopes) do
      {:ok, token}
    else
      GrantTypeError.invalid_scope(scopes)
    end
  end

  defp validate_token_redirect_uri({:error, err, code}, _), do: {:error, err, code}

  defp validate_token_redirect_uri({:ok, token}, redirect_uri) do
    if token.details["redirect_uri"] != redirect_uri do
      GrantTypeError.invalid_client(
        "The redirection URI provided does not match a pre-registered value."
      )
    else
      {:ok, token}
    end
  end

  defp validate_token_expiration({:error, err, code}), do: {:error, err, code}

  defp validate_token_expiration({:ok, token}) do
    if @token_store.is_expired?(token) do
      GrantTypeError.invalid_grant("Token expired.")
    else
      {:ok, token}
    end
  end

  defp validate_client_match({:ok, token}, client) do
    if token.details["client_id"] != client.id do
      GrantTypeError.invalid_grant("Token not found or expired.")
    else
      {:ok, token}
    end
  end
end
