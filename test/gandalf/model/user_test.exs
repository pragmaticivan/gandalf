defmodule Gandalf.Model.UserTest do
  use Gandalf.ModelCase

  @valid_attrs %{email: "foo@example.com", password: "s3cr3tX.", settings: %{locale: "en"}}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = @resource_owner.changeset(%@resource_owner{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = @resource_owner.changeset(%@resource_owner{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "changeset, email too short" do
    changeset =
      @resource_owner.changeset(
        %@resource_owner{},
        Map.put(@valid_attrs, :email, "")
      )

    refute changeset.valid?
  end

  test "changeset, email invalid format" do
    changeset =
      @resource_owner.changeset(
        %@resource_owner{},
        Map.put(@valid_attrs, :email, "foo.com")
      )

    refute changeset.valid?
  end

  test "registration_changeset, encrypt password" do
    changeset = @resource_owner.registration_changeset(%@resource_owner{}, @valid_attrs)
    assert changeset.changes.password
    assert changeset.changes.settings
  end

  test "registration_changeset, password too short" do
    changeset =
      @resource_owner.registration_changeset(
        %@resource_owner{},
        Map.put(@valid_attrs, :password, "1234567")
      )

    refute changeset.valid?
  end

  test "settings_changeset with valid attributes" do
    changeset =
      @resource_owner.settings_changeset(%@resource_owner{}, %{settings: %{language: "tr"}})

    assert changeset.valid?
  end

  test "password_changeset with valid attributes" do
    changeset = @resource_owner.password_changeset(%@resource_owner{}, %{password: "1A2bCx.y"})
    assert changeset.valid?
  end

  test "password_changeset, password too short" do
    changeset = @resource_owner.password_changeset(%@resource_owner{}, %{password: "1A23567"})
    refute changeset.valid?
  end
end
