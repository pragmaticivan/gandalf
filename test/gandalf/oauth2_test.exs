defmodule Gandalf.OAuth2Test do
  use ExUnit.Case
  use Gandalf.RepoBase
  use Gandalf.DB.Test.DataCase
  import Gandalf.Factory
  alias Gandalf.OAuth2
  alias Gandalf.Error.SuspiciousActivity, as: SuspiciousActivityError

  @redirect_uri "https://xyz.com/rd"
  @scopes "read"

  test ".authorize raise when strategy not exist" do
    params = %{"grant_type" => "urn"}
    assert_raise SuspiciousActivityError, fn -> OAuth2.authorize(params) end
  end

  test ".grant_app_authorization delegates with right params" do
    resource_owner = insert(:user)
    client_owner = insert(:user)

    client =
      insert(
        :client,
        user_id: client_owner.id,
        redirect_uri: @redirect_uri
      )

    params = %{"client_id" => client.id, "redirect_uri" => @redirect_uri, "scope" => @scopes}

    OAuth2.grant_app_authorization(resource_owner, params)
    assert_receive :ok
  end

  test ".authorize_app delegates with right params" do
    resource_owner = insert(:user)
    client_owner = insert(:user)

    client =
      insert(
        :client,
        user_id: client_owner.id,
        redirect_uri: @redirect_uri
      )

    params = %{"client_id" => client.id, "redirect_uri" => @redirect_uri, "scope" => @scopes}

    OAuth2.authorize_app(resource_owner, params)
    assert_receive :ok
  end

  test ".revoke_app_authorization delegates with right params" do
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

    OAuth2.revoke_app_authorization(resource_owner, %{"id" => app.id})
    assert_receive :ok
  end
end
