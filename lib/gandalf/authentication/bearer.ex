defmodule Gandalf.Authentication.Bearer do
  @moduledoc """
  Bearer authentication helper module, implements Gandalf.Authentication
  behaviour.
  """

  alias Gandalf.Authentication.Token, as: TokenAuthentication

  @behaviour Gandalf.Authentication

  @doc """
  Authenticates resource-owner using access_token map.
  It reads access_token value from given input and delegates value to
  Gandalf.Authentication.Bearer.authenticate/1 function.
  ## Examples
      # Suppose we have a access_token at 'token store(Gandalf.Token)'
      # with token value "at123456789"
      # If we pass the token value to the function,
      # it will return resource-owner.
      Gandalf.Authentication.Bearer.authenticate(
       %{"access_token" => "at123456789"}, ["read"])
      # or
      Gandalf.Authentication.Bearer.authenticate("at123456789", ["read"])
      # or
      Gandalf.Authentication.Bearer.authenticate("Bearer at123456789",
        ["read"])
  """
  def authenticate(%{"access_token" => access_token}, required_scopes),
    do: authenticate(access_token, required_scopes)

  def authenticate("Bearer " <> access_token, required_scopes),
    do: authenticate(access_token, required_scopes)

  def authenticate(access_token, required_scopes) do
    case TokenAuthentication.authenticate({"access_token", access_token}, required_scopes) do
      {:ok, user} ->
        {:ok, user}

      {:error, errors, status} ->
        {:error, Map.put(errors, :headers, error_headers(errors)), status}
    end
  end

  defp error_headers(errors) do
    error_message = generate_error_header_message(errors)
    [%{"www-authenticate" => "Bearer realm=\"gandalf\", #{error_message}"}]
  end

  defp generate_error_header_message(errors) do
    {error, error_message} =
      errors
      |> Map.to_list()
      |> List.first()

    "error=\"#{error}\", error_description=\"#{error_message}\""
  end
end
