defmodule Gandalf.Authorization.App do
  @moduledoc """
  App Authorization Policy module
  """

  use Gandalf.RepoBase
  import Gandalf.Config, only: [repo: 0, scopes: 0]
  import Ecto.Query, only: [from: 2]

  @doc """
  Authorizes client for resouce owner with given scopes
  It authorizes app to access resouce owner's resouces. Simply, user
  authorizes a client to grant resouces with scopes. If client already
  authorized for resouce owner then it checks scopes and updates when necessary.
  ## Examples
      # For authorization_code grant type
      Gandalf.Authorization.grant(%{
        "user" => %Gandalf.Model.User{...},
        "client_id" => "52024ca6-cf1d-4a9d-bfb6-9bc5023ad56e",
        "redirect_uri" => "http://localhost:4000/oauth2/callbacks",
        "scope" => "read,write"
      %})
  """
  def grant(%{"user" => _, "client_id" => _, "redirect_uri" => _, "scope" => _} = params) do
    params
    |> find_client()
    |> update_or_create_app()
    |> create_token()
  end

  @doc """
  Revokes access to resouce owner's resources.
  Delete all tokens and then removes app for given app identifier.
  ## Examples
      # For revoking client(uninstall app)
      Gandalf.Policy.AppAuthorization.revoke(%{
        "user" => %Gandalf.Model.User{...},
        "id" => "12024ca6-192b-469d-bfb6-9b45023ad13e"
      %})
  """
  def revoke(%{"user" => user, "id" => id}) do
    app = repo().get_by!(@app, id: id, user_id: user.id)
    repo().delete!(app)

    query =
      from(
        t in @token_store,
        where:
          t.user_id == ^app.user_id and fragment("?->>'client_id' = ?", t.details, ^app.client_id)
      )

    repo().delete_all(query)
  end

  defp find_client(%{"client_id" => client_id, "redirect_uri" => redirect_uri} = params) do
    case repo().get_by(@client, id: client_id, redirect_uri: redirect_uri) do
      nil ->
        {:error, %{invalid_client: "Client not found"}, :unprocessable_entity}

      client ->
        Map.put(params, "client", client)
    end
  end

  defp update_or_create_app({:error, errors, status}) do
    {:error, errors, status}
  end

  defp update_or_create_app(
         %{"user" => user, "client_id" => client_id, "scope" => scope} = params
       ) do
    app =
      case repo().get_by(@app, user_id: user.id, client_id: client_id) do
        nil -> create_app(params)
        app -> update_app_scopes({app, scope})
      end

    Map.put(params, "app", app)
  end

  defp update_app_scopes({app, scope}) do
    if app.scope != scope do
      scope =
        scope
        |> Gandalf.Utils.String.comma_split()
        |> Enum.concat(Gandalf.Utils.String.comma_split(app.scope))
        |> Enum.uniq()

      scope = scopes() -- scopes() -- scope
      repo().update!(@app.changeset(app, %{scope: Enum.join(scope, ",")}))
    else
      app
    end
  end

  defp create_app(%{"user" => user, "client_id" => client_id, "scope" => scope}) do
    changeset =
      @app.changeset(%@app{}, %{
        user_id: user.id,
        client_id: client_id,
        scope: scope
      })

    repo().insert!(changeset)
  end

  defp create_token({:error, errors, status}) do
    {:error, errors, status}
  end

  defp create_token(%{"user" => user, "client" => client, "app" => app} = params) do
    changeset =
      @token_store.authorization_code_changeset(%@token_store{}, %{
        user_id: user.id,
        details: %{
          client_id: client.id,
          redirect_uri: client.redirect_uri,
          scope: app.scope
        }
      })

    Map.put(params, "token", repo().insert!(changeset))
  end
end
