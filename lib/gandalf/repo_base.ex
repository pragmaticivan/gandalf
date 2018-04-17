defmodule Gandalf.RepoBase do
  @moduledoc """
  This module allows accessing defined repo models on init.
  """

  defmacro __using__(_) do
    quote do
      alias Gandalf.Model.{User, Token, Client, App}

      @resource_owner Application.get_env(:gandalf, :resource_owner, User)
      @token_store Application.get_env(:gandalf, :token_store, Token)
      @client Application.get_env(:gandalf, :client, Client)
      @app Application.get_env(:gandalf, :app, App)
    end
  end
end
