defmodule Gandalf.RepoBase do
  @moduledoc """
  This module allows accessing defined repo models on init.
  """

  defmacro __using__(_) do
    quote do
      alias Gandalf.Model.{User, Token, Client, App}

      @resource_owner User
      @token_store Token
      @client Client
      @app App
    end
  end
end
