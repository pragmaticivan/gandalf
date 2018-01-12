defmodule Gandalf.Authentication.Error do
  @moduledoc false

  @doc false
  def invalid_request(msg),
    do: {:error, %{invalid_request: msg}, :bad_request}

  @doc false
  def invalid_token(msg), do: {:error, %{invalid_token: msg}, :unauthorized}

  @doc false
  def insufficient_scope(required_scopes) do
    {:error, %{insufficient_scope:
      "Required scopes are #{Enum.join(required_scopes, ", ")}."}, :forbidden}
  end
end
