defmodule GandalfApp do
  @moduledoc """
  Gandalf worker for OAuth2 provider implementation.
  # Usage
  Please refer to hex docs for each module, function details and samples https://hexdocs.pm/gandalf.
  ## Authentication
  Gandalf supports 3 main authentication types by default using Plug.Conn. You can add or remove authentication types using configuration. On successful authentication, resource owner automatically set on `conn.assigns[:current_user]` immutable.
  1) Sessions
  Reads session for configured `sessions` keys and passes to the matched authenticator to authenticate.
  2) Query Params
  Reads query params for configured `query_params` keys and passes to the matched authenticator to authenticate.
  3) Headers
  Reads headers for configured `headers` keys and passes to the matched authenticator to authenticate.
  ### Examples
  Configure your application OAuth2 scopes on configuration. Then add `import Gandalf.Plug.Authenticate` with scopes into your controller.
        defmodule SomeModule.AppController do
          use SomeModule.Web, :controller
          plug Gandalf.Plug.Authenticate [scopes: ~w(read write)]
          def index(conn, _params) do
            # access to current user on successful authentication
            current_user = conn.assigns[:current_user]
            ...
          end
        end
        defmodule SomeModule.AppController do
          use SomeModule.Web, :controller
          use Gandalf.Plug.Authenticate
          plug Gandalf.Plug.Authenticate [scopes: ~w(read write)] when action in [:create]
          def index(conn, _params) do
            # anybody can call this action
            ...
          end
          def create(conn, _params) do
            # only logged in users can access this action
            current_user = conn.assigns[:current_user]
            ...
          end
        end
        # if you need to allow a resource only unauthorized then
        defmodule SomeModule.AppController do
          use SomeModule.Web, :controller
          plug Gandalf.Plug.UnauthorizedOnly when action in [:register]
          def register(conn, _params) do
            # only not logged in user can access this action
          end
        end
  ## OAuth2 Authorization
  Currently, gandalf library supports by default `authorization code`, `client credentials`, `password`, and `refresh token` OAuth2 authorizations. You can add or remove grant types using configuration.
  ### Examples
  To authorize a client for resources, all you need to do is calling `OAuth2.authorize` method with necessary params, on successful authorization `Gandalf.Model.Token` struct will return, on failure {:error, errors, http_status_code}.
        # For authorization_code grant type
        Gandalf.OAuth2.authorize(%{
          "grant_type" => "authorization_code",
          "client_id" => "52024ca6-cf1d-4a9d-bfb6-9bc5023ad56e",
          "client_secret" => "Wi7Y_Q5LU4iIwJArgqXq2Q",
          "redirect_uri" => "http://localhost:4000/oauth2/callbacks",
          "code" => "W_hb8JEDmeYChsNfOGCmbQ",
          "scope" => "read" # optional
        %})
        # For client_credentials grant type
        Gandalf.OAuth2.authorize(%{
          "grant_type" => "client_credentials",
          "client_id" => "52024ca6-cf1d-4a9d-bfb6-9bc5023ad56e",
          "client_secret" => "Wi7Y_Q5LU4iIwJArgqXq2Q",
          "scope" => "read" # optional
        %})
        # For password grant type
        Gandalf.OAuth2.authorize(%{
          "grant_type" => "password",
          "email" => "foo@example.com",
          "password" => "12345678",
          "client_id" => "52024ca6-cf1d-4a9d-bfb6-9bc5023ad56e",
          "scope" => "read" # optional
        %})
        # For refresh_token grant type
        Gandalf.OAuth2.authorize(%{
          "grant_type" => "refresh_token",
          "client_id" => "52024ca6-cf1d-4a9d-bfb6-9bc5023ad56e",
          "client_secret" => "Wi7Y_Q5LU4iIwJArgqXq2Q",
          "refresh_token" => "XJaVz3lCFC9IfifBriA-dw",
          "scope" => "read" # optional
        %})
  ## How a 'OAuth2 Resource Owner' can authorize clients?
  Authorizing client may mean installing client or giving permission to a client to make OAuth2 Authorization requests and allowing resources with selected scopes. To authorize a client for a resource owner, you need to call `OAuth2.authorize_app` function.
  ### Examples
        Gandalf.OAuth2.authorize_app(user, %{
          "client_id" => "52024ca6-cf1d-4a9d-bfb6-9bc5023ad56e",
          "redirect_uri" => "http://localhost:4000/oauth2/callbacks",
          "scope" => "read,write"
        %})
  """

  use Application
  use Gandalf.RepoBase
  import Gandalf.Config, only: [repo: 0]

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      supervisor(repo(), [])
    ]

    opts = [strategy: :one_for_one, name: Gandalf.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
