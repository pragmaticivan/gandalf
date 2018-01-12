defmodule Gandalf.Authentication.ErrorTest do
  use ExUnit.Case
  use Gandalf.DB.Test.DataCase
  alias Gandalf.Authentication.Error

  test "invalid_request" do
    msg = "some"
    expected = {:error, %{invalid_request: msg}, :bad_request}

    assert expected == Error.invalid_request(msg)
  end

  test "invalid_token" do
    msg = "some"
    expected = {:error, %{invalid_token: msg}, :unauthorized}

    assert expected == Error.invalid_token(msg)
  end

  test "insufficient_scope" do
    required_scopes = ~w(read write)
    expected = {:error, %{insufficient_scope:
      "Required scopes are read, write."}, :forbidden}

    assert expected == Error.insufficient_scope(required_scopes)
  end
end
