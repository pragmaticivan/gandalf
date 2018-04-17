defmodule Gandalf.OAuth2 do
  @moduledoc """
  OAuth2 authorization strategy router
  """

  use Gandalf.RepoBase
  import Gandalf.Config, only: [app_authorization: 0, grant_types: 0]

  @doc """
  Calls appropriate module authorize function for given grant type.
  It simply authorizes based on allowed grant types in configuration and then
  returns access token as @token_store(Gandalf.Model.Token) model.
  ## Examples
      # For authorization_code grant type
      Gandalf.OAuth2.authorize(%{
        "grant_type" => "authorization_code",
        "client_id" => "52024ca6-cf1d-4a9d-bfb6-9bc5023ad56e",
        "client_secret" => "Wi7Y_Q5LU4iIwJArgqXq2Q",
        "redirect_uri" => "http://localhost:4000/oauth2/callbacks",
        "code" => "W_hb8JEDmeYChsNfOGCmbQ"
      %})
      # For client_credentials grant type
      Gandalf.OAuth2.authorize(%{
        "grant_type" => "client_credentials",
        "client_id" => "52024ca6-cf1d-4a9d-bfb6-9bc5023ad56e",
        "client_secret" => "Wi7Y_Q5LU4iIwJArgqXq2Q"
      %})
      # For password grant type
      Gandalf.OAuth2.authorize(%{
        "grant_type" => "password",
        "email" => "foo@example.com",
        "password" => "12345678",
        "client_id" => "52024ca6-cf1d-4a9d-bfb6-9bc5023ad56e",
        "scope" => "read"
      %})
      # For refresh_token grant type
      Gandalf.OAuth2.authorize(%{
        "grant_type" => "refresh_token",
        "client_id" => "52024ca6-cf1d-4a9d-bfb6-9bc5023ad56e",
        "client_secret" => "Wi7Y_Q5LU4iIwJArgqXq2Q",
        "refresh_token" => "XJaVz3lCFC9IfifBriA-dw"
      %})
      # For any other grant type; must implement authorize function and returns
      # access_token as @token_store(Gandalf.Model.Token) model.
  """
  def authorize(params) do
    strategy_check(params["grant_type"])
    grant_types()[String.to_atom(params["grant_type"])].authorize(params)
  end

  @doc """
  Authorizes client for resouce owner with given scopes
  It authorizes app to access resouce owner's resouces. Simply, user
  authorizes a client to grant resouces with scopes. If client already
  authorized for resouce owner then it checks scopes and updates when necessary.
  ## Examples
      # For authorization_code grant type
      Gandalf.OAuth2.grant_app_authorization(user, %{
        "client_id" => "52024ca6-cf1d-4a9d-bfb6-9bc5023ad56e",
        "redirect_uri" => "http://localhost:4000/oauth2/callbacks",
        "scope" => "read,write"
      %})
  """
  def grant_app_authorization(user, %{
        "client_id" => client_id,
        "redirect_uri" => redirect_uri,
        "scope" => scope
      }) do
    app_authorization().grant(%{
      "user" => user,
      "client_id" => client_id,
      "redirect_uri" => redirect_uri,
      "scope" => scope
    })
  end

  @doc """
  Warning: Deprecated use grant_app_authorization/2.
  """
  def authorize_app(user, %{
        "client_id" => client_id,
        "redirect_uri" => redirect_uri,
        "scope" => scope
      }) do
    require Logger
    Logger.warn("Warning: Deprecated use OAuth2.grant_app_authorization/2")

    app_authorization().grant(%{
      "user" => user,
      "client_id" => client_id,
      "redirect_uri" => redirect_uri,
      "scope" => scope
    })
  end

  @doc """
  Revokes access to resouce owner's resources.
  Delete all tokens and then removes app for given app identifier.
  ## Examples
      # For revoking client(uninstall app)
      Gandalf.OAuth2.revoke_app_authorization(user, %{
        "id" => "12024ca6-192b-469d-bfb6-9b45023ad13e"
      %})
  """
  def revoke_app_authorization(user, %{"id" => id}) do
    app_authorization().revoke(%{"user" => user, "id" => id})
  end

  defp strategy_check(grant_type) do
    unless Map.has_key?(grant_types(), String.to_atom(grant_type)) do
      raise Gandalf.Error.SuspiciousActivity,
        message: "Strategy for '#{grant_type}' is not enabled!"
    end
  end
end
