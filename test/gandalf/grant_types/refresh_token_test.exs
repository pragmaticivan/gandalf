defmodule Gandalf.GrantType.RefreshTokenTest do
  use ExUnit.Case
  use Gandalf.DB.Test.DataCase
  use Gandalf.RepoBase
  import Gandalf.Config, only: [repo: 0]
  import Gandalf.Factory
  alias Gandalf.GrantType.RefreshToken, as: RefreshTokenGrantType

  setup do
    resource_owner = insert(:user)
    client_owner = insert(:user)
    client = insert(:client, user_id: client_owner.id)
    app = insert(:app, user_id: resource_owner.id, client_id: client.id)

    token =
      insert(
        :refresh_token,
        user_id: resource_owner.id,
        details: %{client_id: client.id, scope: "read"}
      )

    params = %{
      "client_id" => client.id,
      "client_secret" => client.secret,
      "refresh_token" => token.value
    }

    {:ok, [params: params, app: app]}
  end

  test "oauth2 authorization with refresh_token grant type", %{params: params} do
    access_token = RefreshTokenGrantType.authorize(params)
    refute is_nil(access_token)
    assert access_token.details[:grant_type] == "refresh_token"
  end

  test "can not insert access_token more than one with a token with same refresh_token params", %{
    params: params
  } do
    RefreshTokenGrantType.authorize(params)
    {:error, _, http_status} = RefreshTokenGrantType.authorize(params)
    assert http_status == :unauthorized
  end

  test "fails if app is deleted by resource_owner", %{params: params, app: app} do
    repo().delete!(app)
    {:error, _, http_status} = RefreshTokenGrantType.authorize(params)
    assert http_status == :unauthorized
  end
end
