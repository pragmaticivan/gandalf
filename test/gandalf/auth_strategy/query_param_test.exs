defmodule Gandalf.AuthStrategy.QueryParamTest do
  use ExUnit.Case
  use Gandalf.ModelCase
  use Gandalf.ConnCase
  import Gandalf.Factory
  alias Gandalf.AuthStrategy.QueryParam, as: QueryParamStrategy

  setup do
    {:ok, conn: Gandalf.ConnTest.build_conn()}
  end

  test "returns user model when authenticates with access_token query string using valid data", %{conn: conn} do
    user = insert(:user)
    client = insert(:client, user: user)
    token = insert(:access_token, user: user, details: %{client_id: client.id, scope: "read,write"})
    params = %{"access_token" => token.value}
    conn = conn |> fetch_query_params |> Map.put(:query_params, params)
    assert {:ok, user} == QueryParamStrategy.authenticate(conn, ~w(read))
  end

  test "returns :error when fails to authenticates with access_token query string using invalid data", %{conn: conn} do
    params = %{"access_token" => "invalid"}
    conn = conn |> fetch_query_params |> Map.put(:query_params, params)
    {result, _, _} = QueryParamStrategy.authenticate(conn, [])
    assert result == :error
  end

  test "returns nil when no query params matches", %{conn: conn} do
    params = %{}
    conn = conn |> fetch_query_params |> Map.put(:query_params, params)
    assert is_nil(QueryParamStrategy.authenticate(conn, []))
  end
end
