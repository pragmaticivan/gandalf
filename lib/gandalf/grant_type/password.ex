defmodule Gandalf.GrantType.Password do
  @moduledoc """
  Password grant type for OAuth2 Authorization Server
  """

  use Gandalf.RepoBase
  import Gandalf.Config, only: [repo: 0, app_scopes: 0]
  import Gandalf.GrantType.Base
  alias Gandalf.GrantType.Error, as: GrantTypeError
  alias Gandalf.Utils.Crypt, as: CryptUtil

  @behaviour Gandalf.GrantType
  @grant_type "password"

  @doc """
  Authorize client for 'resouce owner' using resouce owner credentials and
  client identifier.
  For authorization, authorize function requires a map contains 'email' and
  'password', 'scope' and 'client_id'. With valid credentials;
  it automatically creates access_token and
  refresh_token(if enabled via config) then it returns
  `Gandalf.Model.Token` struct, otherwise `{:error, Map, :http_status_code}`.
  ## Examples
      Gandalf.GrantType.Password.authorize(%{
        "email" => "foo@example.com",
        "password" => "12345678",
        "client_id" => "52024ca6-cf1d-4a9d-bfb6-9bc5023ad56e",
        "scope" => "read"
      %})
      Gandalf.GrantType.Password.authorize(%{
        "email" => "foo@example.com",
        "password" => "12345678",
        "client_id" => "52024ca6-cf1d-4a9d-bfb6-9bc5023ad56e"
      %})
  """
  def authorize(%{"email" => email, "password" => password, "client_id" => client_id, "scope" => scopes}) do
    client = repo().get(@client, client_id)
    user = repo().get_by(@resource_owner, email: email)
    create_tokens(client, user, password, scopes)
  end
  def authorize(%{"email" => email, "password" => password, "client_id" => client_id}) do
    client = repo().get(@client, client_id)
    user = repo().get_by(@resource_owner, email: email)
    create_tokens(client, user, password, app_scopes())
  end
  def authorize(_) do
    GrantTypeError.invalid_request(
      "Request must include at least email, password and client_id parameters.")
  end

  defp create_tokens(nil, _, _, _),
    do: GrantTypeError.invalid_client("Invalid client id.")
  defp create_tokens(_, nil, _, _),
    do: GrantTypeError.invalid_grant("Identity not found.")
  defp create_tokens(client, user, password, scopes) do
    {:ok, user}
    |> match_with_user_password(password)
    |> validate_token_scope(scopes)
    |> create_oauth2_tokens(client, scopes)
  end

  defp create_oauth2_tokens({:error, err, code}, _, _), do: {:error, err, code}
  defp create_oauth2_tokens({:ok, user}, client, scopes) do
    create_oauth2_tokens(
      user.id, @grant_type, client.id, scopes, client.redirect_uri)
  end

  defp validate_token_scope({:error, err, code}, _), do: {:error, err, code}
  defp validate_token_scope({:ok, user}, ""), do: {:ok, user}
  defp validate_token_scope({:ok, user}, required_scopes) do
    scopes = Gandalf.Utils.String.comma_split(app_scopes())
    required_scopes = Gandalf.Utils.String.comma_split(required_scopes)
    if Gandalf.Utils.List.subset?(scopes, required_scopes) do
      {:ok, user}
    else
      GrantTypeError.invalid_scope(scopes)
    end
  end

  defp match_with_user_password({:ok, user}, password) do
    if CryptUtil.match_password(password, Map.get(user, :password, "")) do
      {:ok, user}
    else
      GrantTypeError.invalid_grant("Identity, password combination is wrong.")
    end
  end
end
