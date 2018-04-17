defmodule Gandalf.Model.AppTest do
  use Gandalf.ModelCase
  import Gandalf.Factory

  setup do
    resource_owner = insert(:user)
    client_owner = insert(:user)
    client = insert(:client, user_id: client_owner.id)
    {:ok, [user_id: resource_owner.id, client_id: client.id]}
  end

  test "changeset with valid attributes", %{user_id: user_id, client_id: client_id} do
    changeset =
      @app.changeset(%@app{}, %{
        scope: "read,write",
        client_id: client_id,
        user_id: user_id
      })

    assert changeset.valid?
  end
end
