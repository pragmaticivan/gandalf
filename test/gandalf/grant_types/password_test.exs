defmodule Gandalf.GrantType.PasswordTest do
  use ExUnit.Case
  use Gandalf.DB.Test.DataCase
  use Gandalf.RepoBase
  import Gandalf.Factory
  alias Gandalf.GrantType.Password, as: PasswordGrantType

  setup do
    resource_owner = insert(:user)
    client_owner = insert(:user)
    client = insert(:client, user_id: client_owner.id)

    params = %{
      "email" => resource_owner.email,
      "password" => "12345678",
      "client_id" => client.id,
      "scope" => "read"
    }

    {:ok, [params: params]}
  end

  test "oauth2 authorization with password grant type", %{params: params} do
    access_token = PasswordGrantType.authorize(params)
    refute is_nil(access_token)
    assert access_token.details[:grant_type] == "password"
  end
end
