defmodule Gandalf.Authentication.BasicTest do
  use ExUnit.Case
  use Gandalf.RepoBase
  use Gandalf.DB.Test.DataCase
  import Gandalf.Factory
  alias Gandalf.Authentication.Basic, as: BasicAuthentication

  setup do
    user = insert(:user)
    basic_auth_token = Base.encode64("#{user.email}:12345678")
    {:ok, [basic_auth_token: basic_auth_token, user: user]}
  end

  test "authorize with basic authentication hash", %{basic_auth_token: basic_auth_token} do
    authorized_user = BasicAuthentication.authenticate(basic_auth_token, [])
    refute is_nil(authorized_user)
  end

  test "authorize with malformed authentication hash" do
    result = BasicAuthentication.authenticate("a:b", [])

    expected =
      {:error,
       %{
         invalid_request: "Invalid credentials encoding.",
         headers: [%{"www-authenticate" => "Basic realm=\"gandalf\""}]
       }, :bad_request}

    assert expected == result
  end

  test "error when non existent email" do
    basic_auth_token = Base.encode64("not-exist@example.com:12345678")
    result = BasicAuthentication.authenticate(basic_auth_token, [])

    expected =
      {:error,
       %{
         invalid_credentials: "Identity not found.",
         headers: [%{"www-authenticate" => "Basic realm=\"gandalf\""}]
       }, :unauthorized}

    assert expected == result
  end

  test "error when wrong password", %{user: user} do
    basic_auth_token = Base.encode64("#{user.email}:wrongpass")
    result = BasicAuthentication.authenticate(basic_auth_token, [])

    expected =
      {:error,
       %{
         invalid_credentials: "Identity, password combination is wrong.",
         headers: [%{"www-authenticate" => "Basic realm=\"gandalf\""}]
       }, :unauthorized}

    assert expected == result
  end

  test "authorize with basic authentication hash using Basic prefix", %{
    basic_auth_token: basic_auth_token
  } do
    authorized_user = BasicAuthentication.authenticate("Basic #{basic_auth_token}", [])
    refute is_nil(authorized_user)
  end
end
