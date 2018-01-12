defmodule Gandalf.GrantType.AuthorizationCodeTest do
  import Gandalf.Config, only: [repo: 0]
  use ExUnit.Case
  use Gandalf.DB.Test.DataCase
  use Gandalf.RepoBase
  import Gandalf.Factory
  alias Gandalf.GrantType.AuthorizationCode, as: AuthorizationCodeGrantType

  @scopes "read"

  setup do
    resource_owner = insert(:user)
    client_owner = insert(:user)
    client = insert(:client, user_id: client_owner.id)
    insert(:app, scope: @scopes, user_id: resource_owner.id, client_id: client.id)
    token = insert(:authorization_code, user_id: resource_owner.id, details: %{client_id: client.id, redirect_uri: client.redirect_uri, scope: @scopes})
    params = %{"client_id" => client.id, "client_secret" => client.secret, "code" => token.value, "redirect_uri" => client.redirect_uri}
    {:ok, [params: params, user_id: resource_owner.id]}
  end

  test "oauth2 authorization with authorization_code grant type", %{params: params} do
    access_token = AuthorizationCodeGrantType.authorize(params)
    refute is_nil(access_token)
    assert access_token.details[:grant_type] == "authorization_code"
  end

  test "oauth2 authorization with authorization_code auto inserts app", %{params: params} do
    AuthorizationCodeGrantType.authorize(params)
    assert Enum.count(repo().all(@app)) > 0
  end

  test "can not insert access_token more than one with a token with same authorization_code params", %{params: params} do
    AuthorizationCodeGrantType.authorize(params)
    {:error, _, http_status} = AuthorizationCodeGrantType.authorize(params)
    assert http_status == :unauthorized
  end
end
