defmodule Gandalf.GrantType.BaseTest do
  use ExUnit.Case
  use Gandalf.DB.Test.DataCase
  use Gandalf.RepoBase
  import Gandalf.Factory
  alias Gandalf.GrantType.Base, as: BaseGrantType

  @scopes "read"

  setup do
    resource_owner = insert(:user)
    client_owner = insert(:user)
    client = insert(:client, user_id: client_owner.id)
    insert(:app, scope: @scopes, user_id: resource_owner.id, client_id: client.id)

    insert(
      :authorization_code,
      user_id: resource_owner.id,
      details: %{client_id: client.id, redirect_uri: client.redirect_uri, scope: @scopes}
    )

    params = %{"client_id" => client.id, "user_id" => resource_owner.id}
    {:ok, [params: params]}
  end

  test "app_authorized? with authorized app for client", %{params: params} do
    assert BaseGrantType.app_authorized?(params["user_id"], params["client_id"])
  end

  test "app_authorized? with unauthorized app for client", %{params: params} do
    client = insert(:client)
    refute BaseGrantType.app_authorized?(params["user_id"], client.id)
  end
end
