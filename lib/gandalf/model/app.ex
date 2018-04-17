defmodule Gandalf.Model.App do
  @moduledoc """
  Installed apps
  """

  use Ecto.Schema
  import Ecto.Changeset
  alias Gandalf.Model.{Client, User}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "apps" do
    field(:scope, :string)
    belongs_to(:client, Client)
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
    |> cast(params, [:scope, :client_id, :user_id])
    |> validate_required([:scope, :client_id, :user_id])
    |> unique_constraint(:client_id, name: :apps_user_id_client_id_index)
  end
end
