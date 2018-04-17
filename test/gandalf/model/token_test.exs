defmodule Gandalf.Model.TokenTest do
  use Gandalf.ModelCase
  import Gandalf.Factory

  setup do
    resource_owner = insert(:user)
    {:ok, [user: resource_owner]}
  end

  test "changeset with valid attributes", %{user: user} do
    changeset =
      @token_store.changeset(%@token_store{}, %{
        user_id: user.id,
        details: %{grant_type: "unknown"}
      })

    assert changeset.valid?
    assert changeset.changes.value
  end

  test "changeset with invalid attributes" do
    changeset = @token_store.changeset(%@token_store{}, %{user_id: 123_456})
    refute changeset.valid?
  end

  test "authorization_code_changeset", %{user: user} do
    changeset =
      @token_store.authorization_code_changeset(%@token_store{}, %{
        user_id: user.id,
        details: %{grant_type: "authorization_code"}
      })

    assert changeset.valid?
    assert changeset.changes.name == "authorization_code"
    assert changeset.changes.expires_at
  end

  test "refresh_token_changeset", %{user: user} do
    changeset =
      @token_store.refresh_token_changeset(%@token_store{}, %{
        user_id: user.id,
        details: %{grant_type: "authorization_code"}
      })

    assert changeset.valid?
    assert changeset.changes.name == "refresh_token"
    assert changeset.changes.expires_at
  end

  test "access_token_changeset", %{user: user} do
    changeset =
      @token_store.access_token_changeset(%@token_store{}, %{
        user_id: user.id,
        details: %{grant_type: "authorization_code"}
      })

    assert changeset.valid?
    assert changeset.changes.name == "access_token"
    assert changeset.changes.expires_at
  end

  test "session_token_changeset", %{user: user} do
    changeset =
      @token_store.session_token_changeset(%@token_store{}, %{
        user_id: user.id,
        details: %{grant_type: "openid"}
      })

    assert changeset.valid?
    assert changeset.changes.name == "session_token"
    assert changeset.changes.expires_at
  end

  test "is_expired true", %{user: user} do
    token = insert(:refresh_token, user_id: user.id, expires_at: :os.system_time(:seconds) - 1)
    assert @token_store.is_expired?(token)
  end

  test "is_expired false", %{user: user} do
    token = insert(:access_token, user_id: user.id)
    assert @token_store.is_expired?(token) == false
  end
end
