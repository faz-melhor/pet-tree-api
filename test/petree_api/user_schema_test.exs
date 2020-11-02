defmodule PetreeApi.UserSchemaTest do
  use PetreeApi.DataCase

  alias PetreeApi.UserSchema

  describe "user" do
    alias PetreeApi.UserSchema.User

    @valid_attrs %{email: "some email", name: "some name", password: "some password"}
    @update_attrs %{
      email: "some updated email",
      name: "some updated name",
      password: "some updated password"
    }
    @invalid_attrs %{email: nil, name: nil, password: nil}

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> UserSchema.create_user()

      user
    end

    test "list_user/0 returns all user" do
      user = user_fixture()
      assert UserSchema.list_user() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert UserSchema.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = UserSchema.create_user(@valid_attrs)
      assert user.email == "some email"
      assert user.name == "some name"
      assert user.password == "some password"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = UserSchema.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      assert {:ok, %User{} = user} = UserSchema.update_user(user, @update_attrs)
      assert user.email == "some updated email"
      assert user.name == "some updated name"
      assert user.password == "some updated password"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = UserSchema.update_user(user, @invalid_attrs)
      assert user == UserSchema.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = UserSchema.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> UserSchema.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = UserSchema.change_user(user)
    end
  end
end
