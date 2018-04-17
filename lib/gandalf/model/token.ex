defmodule Gandalf.Model.Token do
  @moduledoc """
  OAuth2 token store
  """

  use Ecto.Schema
  import Ecto.Changeset
  import Gandalf.Config, only: [app_scopes: 0, expires_in: 0]
  alias Gandalf.Utils.Crypt, as: CryptUtil
  alias Gandalf.Model.User

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "tokens" do
    field(:name, :string)
    field(:value, :string)
    field(:expires_at, :integer)
    field(:details, :map)
    belongs_to(:user, User)

    timestamps()
  end

  @doc """
  Creates a changeset based on the `model` and `params`.
  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, [:name, :expires_at, :details, :user_id])
    |> validate_required([:user_id])
    |> put_token_value
    |> unique_constraint(:value, name: :tokens_value_name_index)
  end

  def authorization_code_changeset(model, params \\ :empty) do
    model
    |> changeset(params)
    |> put_token_name("authorization_code")
    |> put_expires_at(:os.system_time(:seconds) + expires_in()[:authorization_code])
  end

  def refresh_token_changeset(model, params \\ :empty) do
    model
    |> changeset(params)
    |> put_token_name("refresh_token")
    |> put_expires_at(:os.system_time(:seconds) + expires_in()[:refresh_token])
  end

  def access_token_changeset(model, params \\ :empty) do
    model
    |> changeset(params)
    |> put_token_name("access_token")
    |> put_expires_at(:os.system_time(:seconds) + expires_in()[:access_token])
  end

  def session_token_changeset(model, params \\ :empty) do
    model
    |> changeset(params)
    |> put_token_name("session_token")
    |> put_app_scopes
    |> put_expires_at(:os.system_time(:seconds) + expires_in()[:session_token])
  end

  def is_expired?(token) do
    token.expires_at < :os.system_time(:seconds)
  end

  defp put_token_value(model_changeset) do
    put_change(model_changeset, :value, CryptUtil.generate_token())
  end

  defp put_token_name(model_changeset, name) do
    put_change(model_changeset, :name, name)
  end

  defp put_expires_at(model_changeset, expires_at) do
    put_change(model_changeset, :expires_at, expires_at)
  end

  defp put_app_scopes(model_changeset) do
    scopes = app_scopes()
    put_change(model_changeset, :details, %{scope: scopes})
  end
end
