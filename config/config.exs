# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :gandalf, ecto_repos: [Gandalf.DB.Test.Repo]

config :gandalf, Gandalf.DB.Test.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "gandalf_db_test",
  pool: Ecto.Adapters.SQL.Sandbox,
  priv: "priv/temp/gandalf_db_test"


config :gandalf, Gandalf.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "gandalf_dev",
  hostname: "localhost",
  pool_size: 10

config :gandalf,
  ecto_repos: [Gandalf.Repo],
  repo: Gandalf.Repo,
  resource_owner: Gandalf.Model.User,
  token_store: Gandalf.Model.Token,
  client: Gandalf.Model.Client,
  app: Gandalf.Model.App,
  expires_in: %{
    access_token: 3600,
    refresh_token: 24 * 3600,
    authorization_code: 300,
    session_token: 30 * 24 * 3600
  },
  grant_types: %{
    authorization_code: Gandalf.GrantType.AuthorizationCode,
    client_credentials: Gandalf.GrantType.ClientCredentials,
    password: Gandalf.GrantType.Password,
    refresh_token: Gandalf.GrantType.RefreshToken
  },
  auth_strategies: %{
    headers: %{
      "authorization" => [
        {~r/Basic ([a-zA-Z\-_\+=]+)/, Gandalf.Authentication.Basic},
        {~r/Bearer ([a-zA-Z\-_\+=]+)/, Gandalf.Authentication.Bearer},
      ],
      "x-api-token" => [
        {~r/([a-zA-Z\-_\+=]+)/, Gandalf.Authentication.Bearer}
      ]
    },
    query_params: %{
      "access_token" => Gandalf.Authentication.Bearer
    },
    sessions: %{
      "session_token" => Gandalf.Authentication.Session
    }
  },
  scopes: ~w(read write session),
  renderer: Gandalf.Renderer.RestApi
