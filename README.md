# Gandalf

[![CircleCI](https://circleci.com/gh/pragmaticivan/gandalf.svg?style=shield&circle-token=0da837341417ce07c7fcee52a2c98581973cd622)](https://circleci.com/gh/pragmaticivan/gandalf)
[![Hex Version](https://img.shields.io/hexpm/v/gandalf.svg)](https://hex.pm/packages/gandalf)
[![codecov](https://codecov.io/gh/pragmaticivan/gandalf/branch/master/graph/badge.svg?token=MB04JleUFo)](https://codecov.io/gh/pragmaticivan/gandalf)

Elixir Oauth2 Provider implementation forked from https://github.com/mustafaturan/authable and heavily modified

OAuth2 Provider implementation modules and helpers using `plug`, `ecto` and `postgres` for any `elixir` application.

## Installation

The package can be installed as:

  1. Add gandalf to your list of dependencies in `mix.exs`:

      Only for ecto versions > 2.0

```elixir
    def deps do
      [{:gandalf, "~> 0.3.0"}]
    end
```

  2. Add gandalf configurations to your `config/config.exs` file:

  *Important:* You should update `Gandalf.Repo` with your own repo!

```elixir
    config :gandalf,
      ecto_repos: [Gandalf.Repo],
      repo: Gandalf.Repo,
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
```

        If you want to disable a grant type then delete from grant types config.

        If you want to add a new grant type then add your own module with `authorize(params)` function and return a `Gandalf.Model.Token` struct.

  3. Add database configurations for the `Gandalf.Repo` on env config files:

  *Important:* You should update `Gandalf.Repo` with your own repo!

```elixir
    config :gandalf, Gandalf.Repo,
      adapter: Ecto.Adapters.Postgres,
      username: "",
      password: "",
      database: "",
      hostname: "",
      pool_size: 10
```

  4. Run migrations for Gandalf.Repo (Note: all id fields are UUID type):

  *Important:* You should update `Gandalf.Repo` with your own repo!

```elixir
    mix ecto.migrate -r Gandalf.Repo
```

  5. You are ready to go!

## Usage

Please refer to hex docs for each module, function details and samples https://hexdocs.pm/gandalf.

### Authentication

Gandalf supports 3 main authentication types by default using `Plug.Conn`. You can add or remove authentication types using configuration. On successful authentication, resource owner automatically set on `conn.assigns[:current_user]` immutable.

1. **Sessions**. Reads session for configured `sessions` keys and passes to the matched authenticator to authenticate.

2. **Query Params**. Reads query params for configured `query_params` keys and passes to the matched authenticator to authenticate.

3. **Headers**. Reads headers for configured `headers` keys and passes to the matched authenticator to authenticate.

#### Examples

Configure your application OAuth2 scopes on configuration. Then add `import Gandalf.Plug.Authenticate` with scopes into your controller.

```elixir
defmodule SomeModule.AppController do
  use SomeModule.Web, :controller
  plug Gandalf.Plug.Authenticate, [scopes: ~w(read write)]

  def index(conn, _params) do
    # access to current user on successful authentication
    # ...
    # current_user = conn.assigns[:current_user]
  end
end

defmodule SomeModule.AppController do
  use SomeModule.Web, :controller

  plug Gandalf.Plug.Authenticate, [scopes: ~w(read write)] when action in [:create]

  def index(conn, _params) do
    # anybody can call this action
    # ...
  end

  def create(conn, _params) do
    # only logged in users can access this action
    # ...
    # current_user = conn.assigns[:current_user]
  end
end

# if you need to allow a resource only unauthorized then
defmodule SomeModule.AppController do
  use SomeModule.Web, :controller
  plug Gandalf.Plug.UnauthorizedOnly when action in [:register]

  def register(conn, _params) do
    # only not logged in user can access this action
    # ...
  end
end
```

On failure of authentication, gandalf renders as a RestApi json format, if you need to change the format file you need to implement the behaviour of `Gandalf.Renderer` and then change the `renderer` configuration.

### OAuth2 Authorization

Currently, gandalf library supports by default `authorization code`, `client credentials`, `password`, and `refresh token` OAuth2 authorizations. You can add or remove grant types using configuration.

#### Examples

To authorize a client for resources, all you need to do is calling `OAuth2.authorize` method with necessary params, on successful authorization `Gandalf.Model.Token` struct will return, on failure `{:error, errors, http_status_code}`.

```elixir
# For authorization_code grant type
Gandalf.OAuth2.authorize(%{
  "grant_type" => "authorization_code",
  "client_id" => "52024ca6-cf1d-4a9d-bfb6-9bc5023ad56e",
  "client_secret" => "Wi7Y_Q5LU4iIwJArgqXq2Q",
  "redirect_uri" => "http://localhost:4000/oauth2/callbacks",
  "code" => "W_hb8JEDmeYChsNfOGCmbQ",
  "scope" => "read" # optional
})

# For client_credentials grant type
Gandalf.OAuth2.authorize(%{
  "grant_type" => "client_credentials",
  "client_id" => "52024ca6-cf1d-4a9d-bfb6-9bc5023ad56e",
  "client_secret" => "Wi7Y_Q5LU4iIwJArgqXq2Q",
  "scope" => "read" # optional
})

# For password grant type
Gandalf.OAuth2.authorize(%{
  "grant_type" => "password",
  "email" => "foo@example.com",
  "password" => "12345678",
  "client_id" => "52024ca6-cf1d-4a9d-bfb6-9bc5023ad56e",
  "scope" => "read" # optional
})

# For refresh_token grant type
Gandalf.OAuth2.authorize(%{
  "grant_type" => "refresh_token",
  "client_id" => "52024ca6-cf1d-4a9d-bfb6-9bc5023ad56e",
  "client_secret" => "Wi7Y_Q5LU4iIwJArgqXq2Q",
  "refresh_token" => "XJaVz3lCFC9IfifBriA-dw",
  "scope" => "read" # optional
})

# You can adjust token expiration durations from configuration.
```

### How a 'OAuth2 Resource Owner' can authorize clients?

Authorizing client may mean installing client or giving permission to a client to make OAuth2 Authorization requests and allowing resources with selected scopes. To authorize a client for a resource owner, you need to call `OAuth2.authorize_app` function.

#### Examples

```elixir
Gandalf.OAuth2.authorize_app(user, %{
  "client_id" => "52024ca6-cf1d-4a9d-bfb6-9bc5023ad56e",
  "redirect_uri" => "http://localhost:4000/oauth2/callbacks",
  "scope" => "read,write"
})
```

### Changing models

To change models, you have two options:

1. You may change the module name from configuration,
2. You may copy Gandalf.Model.XXX and update it on your app.

## Test

To run tests, jump into gandalf directory and run the command:

```shell
mix test
```

## Contributing

### Issues, Bugs, Documentation, Enhancements

1. Fork the project

2. Make your improvements and write your tests.

3. Make a pull request.

### To add new strategy:

Gandalf is an extensible module, you can create your strategy and share as hex package(Which can be listed on Wiki pages).

## Todo

- HMAC Auth will be added as a new external strategy

## References

* https://tools.ietf.org/html/rfc6749

* https://tools.ietf.org/html/rfc6750
