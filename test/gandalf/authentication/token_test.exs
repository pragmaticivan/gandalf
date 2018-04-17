defmodule Gandalf.Authentication.TokenTest do
  use ExUnit.Case
  use Gandalf.RepoBase
  import Gandalf.Factory
  use Gandalf.DB.Test.DataCase
  alias Gandalf.Authentication.Token, as: TokenAuthentication

  @expired_token_value "expired_token_1234"
  @access_token_value "access_token_1234"
  @session_token_value "session_token_1234"
  @deleted_user_token_value "deleted_token_1234"

  setup do
    user = insert(:user)
    second_user = insert(:user)

    insert(:access_token, %{
      value: @expired_token_value,
      user: user,
      expires_at: :os.system_time(:seconds) - 1000
    })

    insert(:access_token, %{value: @access_token_value, user: user})
    insert(:access_token, %{value: @deleted_user_token_value, user: second_user})
    insert(:session_token, %{value: @session_token_value, user: user})
    :ok
  end

  test "authorize with bearer token" do
    authorized_user =
      case TokenAuthentication.authenticate({"access_token", @access_token_value}, []) do
        {:error, _, _} -> nil
        user -> user
      end

    refute is_nil(authorized_user)
  end

  test "error when expired token given" do
    {:error, _, status} =
      TokenAuthentication.authenticate({"access_token", @expired_token_value}, [])

    assert :unauthorized == status
  end

  test "error when insufficient scopes" do
    {:error, _, status} =
      TokenAuthentication.authenticate({"access_token", @access_token_value}, ["write"])

    assert :forbidden == status
  end

  test "authorize with session token" do
    authorized_user =
      case TokenAuthentication.authenticate({"session_token", @session_token_value}, []) do
        {:error, _, _} -> nil
        user -> user
      end

    refute is_nil(authorized_user)
  end
end
