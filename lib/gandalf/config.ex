defmodule Gandalf.Config do
  @moduledoc """
  Gandalf lib config module
  """

  alias Gandalf.Authorization.App, as: AppAuthorization

  def repo,
    do: Application.get_env(:gandalf, :repo)

  def scopes,
    do: Application.get_env(:gandalf, :scopes)

  def app_scopes,
    do: Enum.join(scopes(), ",")

  def grant_types,
    do: Application.get_env(:gandalf, :grant_types)

  def auth_strategies,
    do: Application.get_env(:gandalf, :auth_strategies)

  def header_auth,
    do: Map.get(auth_strategies(), :headers)

  def query_params_auth,
    do: Map.get(auth_strategies(), :query_params)

  def session_auth,
    do: Map.get(auth_strategies(), :sessions)

  def expires_in,
    do: Application.get_env(:gandalf, :expires_in)

  def renderer,
    do: Application.get_env(:gandalf, :renderer)

  def app_authorization do
    Application.get_env(:gandalf, :app_authorization, AppAuthorization)
  end
end
