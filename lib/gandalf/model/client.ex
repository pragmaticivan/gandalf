defmodule Gandalf.Model.Client do
  @moduledoc """
  OAuth2 client
  """

  use Ecto.Schema
  import Ecto.Changeset
  alias Gandalf.Utils.Crypt, as: CryptUtil
  alias Gandalf.Model.{App, User}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "clients" do
    field(:name, :string)
    field(:secret, :string)
    field(:redirect_uri, :string)
    field(:settings, :map)
    field(:priv_settings, :map)
    belongs_to(:user, User)
    has_many(:apps, App)

    timestamps()
  end

  @doc """
  Creates a changeset based on the `model` and `params`.
  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, [:name, :redirect_uri, :settings, :priv_settings, :user_id])
    |> validate_required([:name, :redirect_uri, :user_id])
    |> validate_length(:name, min: 4, max: 32)
    |> validate_format(:name, ~r/\A([a-zA-Z]+)([0-9a-zA-Z]*)\z/i)
    |> unique_constraint(:name)
    |> put_secret
  end

  defp put_secret(model_changeset) do
    put_change(model_changeset, :secret, CryptUtil.generate_token())
  end
end
