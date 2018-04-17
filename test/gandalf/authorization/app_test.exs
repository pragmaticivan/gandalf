defmodule Gandalf.Authorization.AppTest do
  use ExUnit.Case
  use Gandalf.RepoBase
  use Gandalf.DB.Test.DataCase
  import Gandalf.Config, only: [repo: 0]
  import Gandalf.Factory
  import Ecto.Query, only: [where: 2]
  alias Gandalf.Authorization.App, as: AppAuthorization

  @redirect_uri "https://xyz.com/rd"
  @scopes "read"

  test "resource_owner authorize app for a client" do
    resource_owner = insert(:user)
    client_owner = insert(:user)

    client =
      insert(
        :client,
        user_id: client_owner.id,
        redirect_uri: @redirect_uri
      )

    params = %{
      "user" => resource_owner,
      "client_id" => client.id,
      "redirect_uri" => @redirect_uri,
      "scope" => @scopes
    }

    app = AppAuthorization.grant(params)

    refute is_nil(app)
  end

  test "resource_owner re-authorize app with new scopes for a client" do
    new_scopes = "read,write"
    resource_owner = insert(:user)
    client_owner = insert(:user)

    client =
      insert(
        :client,
        user_id: client_owner.id,
        redirect_uri: @redirect_uri
      )

    app = insert(:app, user_id: resource_owner.id, client_id: client.id, scope: @scopes)

    params = %{
      "user" => resource_owner,
      "client_id" => client.id,
      "redirect_uri" => @redirect_uri,
      "scope" => new_scopes
    }

    result = AppAuthorization.grant(params)

    same_app = Map.get(result, "app")
    assert app.id == same_app.id
    assert new_scopes == same_app.scope
  end

  test "resource_owner re-authorize app with old scopes for a client" do
    resource_owner = insert(:user)
    client_owner = insert(:user)

    client =
      insert(
        :client,
        user_id: client_owner.id,
        redirect_uri: @redirect_uri
      )

    app = insert(:app, user_id: resource_owner.id, client_id: client.id, scope: @scopes)

    params = %{
      "user" => resource_owner,
      "client_id" => client.id,
      "redirect_uri" => @redirect_uri,
      "scope" => @scopes
    }

    result = AppAuthorization.grant(params)

    same_app = Map.get(result, "app")
    assert app.id == same_app.id
    assert @scopes == same_app.scope
  end

  test "does not allow to change redirect_uri when authorize app" do
    resource_owner = insert(:user)
    client_owner = insert(:user)

    client =
      insert(
        :client,
        user_id: client_owner.id,
        redirect_uri: @redirect_uri
      )

    params = %{
      "user" => resource_owner,
      "client_id" => client.id,
      "redirect_uri" => "https://xyz.com/nx",
      "scope" => @scopes
    }

    {:error, _, http_status_code} = AppAuthorization.grant(params)

    assert http_status_code == :unprocessable_entity
  end

  test "deletes app and user's all client tokens" do
    resource_owner = insert(:user)
    client_owner = insert(:user)

    client =
      insert(
        :client,
        user_id: client_owner.id,
        redirect_uri: @redirect_uri
      )

    app = insert(:app, user_id: resource_owner.id, client_id: client.id, scope: @scopes)

    insert(
      :access_token,
      user_id: resource_owner.id,
      details: %{
        client_id: client.id
      }
    )

    insert(
      :refresh_token,
      user_id: resource_owner.id,
      details: %{
        client_id: client.id
      }
    )

    params = %{"user" => resource_owner, "id" => app.id}
    AppAuthorization.revoke(params)

    tokens =
      @token_store
      |> where(user_id: ^resource_owner.id)
      |> repo().all

    assert Enum.count(tokens) == 0
    assert is_nil(repo().get(@app, app.id))
  end
end
