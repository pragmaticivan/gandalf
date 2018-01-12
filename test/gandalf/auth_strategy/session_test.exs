defmodule Gandalf.AuthStrategy.SessionTest do
  use ExUnit.Case
  use Gandalf.ModelCase
  use Gandalf.ConnCase
  import Gandalf.Factory
  alias Gandalf.AuthStrategy.Session, as: SessionAuthStrategy

  @default_opts [
    store: :cookie,
    key: "foobar",
    encryption_salt: "encrypted cookie salt",
    signing_salt: "signing salt",
    log: false
  ]

  @secret String.duplicate("abcdef0123456789", 8)
  @signing_opts Plug.Session.init(Keyword.put(@default_opts, :encrypt, false))

  setup do
    {:ok, conn: Gandalf.ConnTest.build_conn()}
  end

  defp sign_conn(conn) do
    put_in(conn.secret_key_base, @secret)
    |> Plug.Session.call(@signing_opts)
    |> fetch_session
  end

  test "returns user model when authenticates with session using valid data", %{conn: conn} do
    user = insert(:user)
    token = insert(:session_token, user_id: user.id)
    conn = conn |> sign_conn |> put_session(:session_token, token.value)
    assert {:ok, user} == SessionAuthStrategy.authenticate(conn, [])
  end

  test "returns error when authenticates with session using invalid data", %{conn: conn} do
    insert(:session_token, user_id: insert(:user).id)
    conn = conn |> sign_conn |> put_session(:session_token, "wrong_session_val")
    {result, _, _} = SessionAuthStrategy.authenticate(conn, [])
    assert result == :error
  end

  test "returns nil when authenticates when session key not exists", %{conn: conn} do
    insert(:session_token, user_id: insert(:user).id)
    conn = conn |> sign_conn
    assert SessionAuthStrategy.authenticate(conn, []) == nil
  end
end
