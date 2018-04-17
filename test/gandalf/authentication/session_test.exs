defmodule Gandalf.Authentication.SessionTest do
  use ExUnit.Case
  use Gandalf.RepoBase
  use Gandalf.DB.Test.DataCase
  import Gandalf.Factory
  alias Gandalf.Authentication.Session, as: SessionAuthentication

  @session_token_value "session_token_1234"

  setup do
    insert(:session_token, %{value: @session_token_value, user: insert(:user)})
    :ok
  end

  test "authorize with session auth token" do
    {:ok, authorized_user} = SessionAuthentication.authenticate(@session_token_value, [])
    refute is_nil(authorized_user)
  end
end
