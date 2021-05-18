defmodule PetreeApi.AccountsTest do
  use PetreeApi.DataCase

  import PetreeApi.Factory

  alias PetreeApi.Accounts

  describe "users" do
    alias PetreeApi.Accounts.User

    test "list_users/0 returns all users" do
      user = insert(:user)

      assert users = Accounts.list_users(User)
      assert users == [user]
      assert length(users) == 1
    end

    test "get_user!/1 returns the user with given id" do
      user = insert(:user)

      assert user == Accounts.get_user!(user.id)
    end

    test "create_user/1 with valid data creates a user" do
      user = build(:user, password: "123456")

      assert {:ok, %User{} = created_user} = Accounts.create_user(user |> Map.from_struct())
      assert user.email == created_user.email
      assert user.name == created_user.name
      assert user.nickname == created_user.nickname
    end

    test "create_user/1 with invalid name returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               Accounts.create_user(build(:user, name: nil) |> Map.from_struct())
    end

    test "create_user/1 with invalid email returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               Accounts.create_user(build(:user, email: nil) |> Map.from_struct())
    end

    test "create_user/1 with invalid nickname returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               Accounts.create_user(build(:user, nickname: nil) |> Map.from_struct())
    end

    test "create_user/1 with invalid password returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(build(:user) |> Map.from_struct())
    end

    test "update_user/2 with valid name updates the user" do
      user = insert(:user)

      assert {:ok, %User{} = user} = Accounts.update_user(user, %{name: "Janet Smith"})
      assert user.name == "Janet Smith"
    end

    test "update_user/2 with valid email updates the user" do
      user = insert(:user)

      assert {:ok, %User{} = user} = Accounts.update_user(user, %{email: "email2@mail.com"})
      assert user.email == "email2@mail.com"
    end

    test "update_user/2 with valid nickname updates the user" do
      user = insert(:user)

      assert {:ok, %User{} = user} = Accounts.update_user(user, %{nickname: "Janet"})
      assert user.nickname == "Janet"
    end

    test "update_user/2 with valid password updates the user" do
      user = insert(:user)

      assert {:ok, %User{} = updated_user} = Accounts.update_user(user, %{password: "12345"})
      assert updated_user.password_hash != user.password_hash
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = insert(:user)

      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, %{email: "email"})
      assert user == Accounts.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = insert(:user)
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = build(:user)
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end
end
