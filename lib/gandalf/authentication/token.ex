defmodule Gandalf.Authentication.Token do
  @moduledoc """
  Base token authentication helper, implements Gandalf.Authentication
  behaviour. Differently from Bearer or Session, this module is a generic
  helper module. It enables to match with any token type from
  'token store(Gandalf.Token)'.
  """

  alias Gandalf.Authentication.Error, as: AuthenticationError

  @behaviour Gandalf.Authentication
  @repo Application.get_env(:gandalf, :repo)
  @resource_owner Application.get_env(:gandalf, :resource_owner)
  @token_store Application.get_env(:gandalf, :token_store)

  @doc """
  Authenticates resource-owner using given token name and value pairs.
  It matches resource owner with given token name and value.
  If any resource owner matched given credentials,
  it returns `Gandalf.Model.User` struct, otherwise
  `{:error, Map, :http_status_code}`.
  ## Examples
      # Suppose we store a confirmation_token at 'token store'
      # with token value "ct123456789"
      # If we pass the token value to the function,
      # it will return resource-owner.
      Gandalf.Authentication.Token.authenticate({"confirmation_token",
        "ct123456789"}, ["read", "write"])
  """
  def authenticate({token_name, token_value}, required_scopes) do
    token_check(
      @repo.get_by(@token_store, value: token_value, name: token_name),
      required_scopes
    )
  end

  defp token_check(nil, _), do: AuthenticationError.invalid_token("Token not found.")

  defp token_check(token, required_scopes) do
    if @token_store.is_expired?(token) do
      AuthenticationError.invalid_token("Token expired.")
    else
      scopes = Gandalf.Utils.String.comma_split(token.details["scope"])

      if Gandalf.Utils.List.subset?(scopes, required_scopes) do
        resource_owner_check(@repo.get(@resource_owner, token.user_id))
      else
        AuthenticationError.insufficient_scope(required_scopes)
      end
    end
  end

  defp resource_owner_check(nil), do: AuthenticationError.invalid_token("User not found.")
  defp resource_owner_check(resource_owner), do: {:ok, resource_owner}
end
