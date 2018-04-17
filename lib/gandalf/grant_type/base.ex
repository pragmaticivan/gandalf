defmodule Gandalf.GrantType.Base do
  @moduledoc """
  Base module for OAuth2 grant types
  """

  use Gandalf.RepoBase
  import Gandalf.Config, only: [repo: 0, grant_types: 0, scopes: 0]

  @doc """
  A common function to generate oauth2 tokens (access_token and refresh_token)
  for all Gandalf.GrantType.
  To create oauth2 tokens, function requires valid 'resource owner model',
  'grant_type', 'client_id', 'scope' and as optional 'redirect_uri'.
  It automatically checks given scopes against configuration scopes and if any
  invalid scope occurs then it raises an exception with type of
  Gandalf.Error.SuspiciousActivity.
  It automatically checks the refresh_token strategy from configuration params
  and creates if enabled, otherwise it skips creation.
  ## Examples
      Gandalf.GrantType.Base.create_oauth2_tokens(user, "refresh_token",
        "52024ca6-cf1d-4a9d-bfb6-9bc5023ad56e", "read",
        "http://localhost:4000/oauth2/callbacks")
  """
  def create_oauth2_tokens(user_id, grant_type, client_id, scope, redirect_uri \\ nil) do
    scopes_check(scope)

    user_id
    |> build_token_params(grant_type, client_id, scope, redirect_uri)
    |> put_refresh_token?(grant_types()[:refresh_token])
    |> create_access_token
  end

  @doc """
  A common function for all Gandalf.GrantType to check if the client
  authorized for the given resource owner. Returns either true or false,
  depending on status of authorization.
  ## Examples
      Gandalf.GrantType.Base.app_authorized?(
        "256a6d70-4a91-43fe-aacf-5588862ed8a2"
        "52024ca6-cf1d-4a9d-bfb6-9bc5023ad56e"
      )
  """
  def app_authorized?(user_id, client_id),
    do: !is_nil(repo().get_by(@app, user_id: user_id, client_id: client_id))

  defp scopes_check(scopes) do
    valid_scopes = scopes()
    desired_scopes = Gandalf.Utils.String.comma_split(scopes)
    Enum.each(desired_scopes, fn scope -> scope_check(valid_scopes, scope) end)
  end

  defp scope_check(valid_scopes, scope) do
    unless Enum.member?(valid_scopes, scope) do
      raise Gandalf.Error.SuspiciousActivity, message: "Scope: #{scope} is not supported!"
    end
  end

  defp build_token_params(user_id, grant_type, client_id, scope, redirect_uri) do
    %{
      user_id: user_id,
      details: %{
        grant_type: grant_type,
        client_id: client_id,
        scope: scope,
        redirect_uri: redirect_uri
      }
    }
  end

  defp put_refresh_token?(token_params, true), do: put_refresh_token(token_params)
  defp put_refresh_token?(token_params, _), do: token_params

  defp put_refresh_token(token_params) do
    refresh_token_changeset =
      @token_store.refresh_token_changeset(
        %@token_store{},
        token_params
      )

    case repo().insert(refresh_token_changeset) do
      {:ok, refresh_token} ->
        token_params
        |> Map.merge(%{
          details: Map.put(token_params[:details], :refresh_token, refresh_token.value)
        })

      :error ->
        token_params
    end
  end

  defp create_access_token(token_params) do
    access_token_changeset =
      @token_store.access_token_changeset(
        %@token_store{},
        token_params
      )

    case repo().insert(access_token_changeset) do
      {:ok, access_token} -> access_token
    end
  end
end
