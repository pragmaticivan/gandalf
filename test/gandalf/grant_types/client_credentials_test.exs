defmodule Gandalf.GrantType.ClientCredentialsTest do
  use ExUnit.Case
  use Gandalf.DB.Test.DataCase
  use Gandalf.RepoBase
  import Gandalf.Factory
  alias Gandalf.GrantType.ClientCredentials, as: ClientCredentialsGrantType

  setup do
    client_owner = insert(:user)
    client = insert(:client, user_id: client_owner.id)
    params = %{"client_id" => client.id, "client_secret" => client.secret}
    {:ok, [params: params]}
  end

  test "oauth2 authorization with client_credentials grant type", %{params: params} do
    access_token = ClientCredentialsGrantType.authorize(params)
    refute is_nil(access_token)
    assert access_token.details[:grant_type] == "client_credentials"
  end
end
