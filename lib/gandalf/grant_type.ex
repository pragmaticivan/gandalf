defmodule Gandalf.GrantType do
  @moduledoc """
  A behaviour for all grant type modules called by other Gandalf modules.
  ## Creating a custom module
  If you are going to create a custom grant type module, then you need to
  implement following function:
    * `authorize`
  """

  @doc """
  Finds and returns Resource Owner(User) struct using a param(param can be any
  type).
  This function returns a `{:ok, Gandalf.Model.Token struct}` or
  `{:error, Map, :http_status_code}`.
  """
  @callback authorize(any) :: {:ok, Gandalf.Token} | {:error, Map, Atom}
end
