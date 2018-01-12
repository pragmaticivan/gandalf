defmodule Gandalf.Model.User do
  @moduledoc """
  OAuth2 resource owner
  """

  use Ecto.Schema
  import Ecto.Changeset
  alias Gandalf.Utils.Crypt, as: CryptUtil
  alias Gandalf.Model.{Token, Client, App}

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "users" do
    field :email, :string
    field :password, :string
    field :settings, :map
    field :priv_settings, :map
    has_many :clients, Client
    has_many :tokens, Token
    has_many :apps, App

    timestamps()
  end

  @doc """
  Creates a changeset based on the `model` and `params`.
  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, [:email, :password, :settings])
    |> validate_required([:email, :password])
    |> validate_length(:email, min: 6, max: 255)
    |> validate_format(:email,
         ~r/\A([\w+\-]\.?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i)
  end

  def settings_changeset(model, params \\ :empty) do
    model
    |> cast(params, [:settings])
    |> validate_required([:settings])
  end

  def registration_changeset(model, params \\ :empty) do
    model
    |> changeset(params)
    |> unique_constraint(:email)
    |> cast(params, [:password])
    |> validate_length(:password, min: 8, max: 32)
    |> put_password_hash
    |> put_unconfirmed_flag
  end

  def password_changeset(model, params) do
    model
    |> cast(params, [:password])
    |> validate_required([:password])
    |> validate_length(:password, min: 8, max: 32)
    |> put_password_hash
  end

  defp put_password_hash(model_changeset) do
    case model_changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: pass}} ->
        put_change(model_changeset, :password, CryptUtil.salt_password(pass))
      _ ->
        model_changeset
    end
  end

  defp put_unconfirmed_flag(model_changeset) do
    case model_changeset do
      %Ecto.Changeset{valid?: true, changes: %{settings: user_settings}} ->
        put_change(model_changeset, :settings, Map.put(user_settings,
          :confirmed, false))
      _ ->
        model_changeset
    end
  end
end
