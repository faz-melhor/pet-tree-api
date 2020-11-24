defmodule PetreeApi.TreesTest do
  use PetreeApi.DataCase

  import PetreeApi.Factory

  alias PetreeApi.Accounts.User
  alias PetreeApi.Trees

  describe "trees" do
    alias PetreeApi.Trees.Tree

    test "list_trees/0 returns all trees" do
      tree = insert(:tree)

      assert trees = Trees.list_trees()
      assert is_list(trees)
      assert length(trees) == 1
      assert tree.user_id == Enum.at(trees, 0).user_id
    end

    test "get_tree!/1 returns the tree with given id" do
      %Tree{description: description, id: id} = insert(:tree)

      assert %Tree{description: ^description} = Trees.get_tree!(id)
    end

    test "create_tree/1 with valid data creates a tree" do
      user = insert(:user)
      tree = build(:tree, user: user, user_id: user.id)

      assert {:ok, %Tree{} = created_tree} = Trees.create_tree(tree |> Map.from_struct())
      assert tree.description == created_tree.description
      assert tree.fruitful == created_tree.fruitful
      assert tree.lat == created_tree.lat
      assert tree.lng == created_tree.lng
      assert tree.status == created_tree.status
      assert tree.specie == created_tree.specie
      assert tree.user_id == created_tree.user_id
    end

    test "create_tree/1 without user id returns error changeset" do
      # build a tree without user id
      tree = build(:tree)
      assert {:error, %Ecto.Changeset{}} = Trees.create_tree(tree |> Map.from_struct())
    end

    test "create_tree/1 with invalid fruitful data returns error changeset" do
      user = insert(:user)
      tree = build(:tree, fruitful: 1, user: user)

      assert {:error, %Ecto.Changeset{}} = Trees.create_tree(tree |> Map.from_struct())
    end

    test "create_tree/1 with invalid latatitude data returns error changeset" do
      user = insert(:user)
      tree = build(:tree, lat: "lat", user: user)

      assert {:error, %Ecto.Changeset{}} = Trees.create_tree(tree |> Map.from_struct())
    end

    test "create_tree/1 with invalid longitude data returns error changeset" do
      user = insert(:user)
      tree = build(:tree, lng: "lng", user: user)

      assert {:error, %Ecto.Changeset{}} = Trees.create_tree(tree |> Map.from_struct())
    end

    test "create_tree/1 with invalid specie data returns error changeset" do
      user = insert(:user)
      tree = build(:tree, specie: 1, user: user)

      assert {:error, %Ecto.Changeset{}} = Trees.create_tree(tree |> Map.from_struct())
    end

    test "create_tree/1 with invalid status data returns error changeset" do
      user = insert(:user)
      tree = build(:tree, status: :ok, user: user)

      assert {:error, %Ecto.Changeset{}} = Trees.create_tree(tree |> Map.from_struct())
    end

    test "update_tree/2 with valid description data updates the tree" do
      user = insert(:user)
      tree = insert(:tree, user: user)
      description = "New Description"

      assert {:ok, %Tree{} = tree} = Trees.update_tree(tree, %{description: description})
      assert tree.description == description
    end

    test "update_tree/2 with valid fruitful data updates the tree" do
      user = insert(:user)
      tree = insert(:tree, user: user)
      fruiful = false

      assert {:ok, %Tree{} = tree} = Trees.update_tree(tree, %{fruitful: fruiful})
      assert tree.fruitful == fruiful
    end

    test "update_tree/2 with valid latitude data updates the tree" do
      user = insert(:user)
      tree = insert(:tree, user: user)
      lat = Decimal.new("10.0")

      assert {:ok, %Tree{} = tree} = Trees.update_tree(tree, %{lat: lat})
      assert tree.lat == lat
    end

    test "update_tree/2 with valid longitude data updates the tree" do
      user = insert(:user)
      tree = insert(:tree, user: user)
      lng = Decimal.new("10.0")

      assert {:ok, %Tree{} = tree} = Trees.update_tree(tree, %{lng: lng})
      assert tree.lng == lng
    end

    test "update_tree/2 with valid specie data updates the tree" do
      user = insert(:user)
      tree = insert(:tree, user: user)
      specie = "Citrus Limon"

      assert {:ok, %Tree{} = tree} = Trees.update_tree(tree, %{specie: specie})
      assert tree.specie == specie
    end

    test "update_tree/2 with valid user id updates the tree" do
      user = insert(:user)
      tree = insert(:tree, user: user)
      %User{id: user_id} = insert(:user)

      assert {:ok, %Tree{} = tree} = Trees.update_tree(tree, %{user_id: user_id})
      assert tree.user_id == user_id
    end

    test "update_tree/2 with valid status data updates the tree" do
      user = insert(:user)
      tree = insert(:tree, user: user)
      status = :accepted

      assert {:ok, %Tree{} = tree} = Trees.update_tree(tree, %{status: status})
      assert tree.status == status
    end

    test "update_tree/2 with invalid user id returns error changeset" do
      user = insert(:user)
      tree = insert(:tree, user: user)
      invalid_user_id = nil

      assert {:error, %Ecto.Changeset{}} = Trees.update_tree(tree, %{user_id: invalid_user_id})
      assert tree = Trees.get_tree!(tree.id)
      assert tree.user_id != invalid_user_id
    end

    test "update_tree/2 with invalid description data returns error changeset" do
      user = insert(:user)
      tree = insert(:tree, user: user)
      invalid_description = 1

      assert {:error, %Ecto.Changeset{}} =
               Trees.update_tree(tree, %{description: invalid_description})

      assert tree = Trees.get_tree!(tree.id)
      assert tree.description != invalid_description
    end

    test "update_tree/2 with invalid fruitful data returns error changeset" do
      user = insert(:user)
      tree = insert(:tree, user: user)
      invalid_fruitful = 1

      assert {:error, %Ecto.Changeset{}} = Trees.update_tree(tree, %{user_id: invalid_fruitful})
      assert tree = Trees.get_tree!(tree.id)
      assert tree.fruitful != invalid_fruitful
    end

    test "update_tree/2 with invalid latitude data returns error changeset" do
      user = insert(:user)
      tree = insert(:tree, user: user)
      invalid_latitude = "lat"

      assert {:error, %Ecto.Changeset{}} = Trees.update_tree(tree, %{user_id: invalid_latitude})
      assert tree = Trees.get_tree!(tree.id)
      assert tree.lat != invalid_latitude
    end

    test "update_tree/2 with invalid longitude data returns error changeset" do
      user = insert(:user)
      tree = insert(:tree, user: user)
      invalid_longitude = "lng"

      assert {:error, %Ecto.Changeset{}} = Trees.update_tree(tree, %{lng: invalid_longitude})
      assert tree = Trees.get_tree!(tree.id)
      assert tree.lng != invalid_longitude
    end

    test "update_tree/2 with invalid specie data returns error changeset" do
      user = insert(:user)
      tree = insert(:tree, user: user)
      invalid_specie = 1

      assert {:error, %Ecto.Changeset{}} = Trees.update_tree(tree, %{specie: invalid_specie})
      assert tree = Trees.get_tree!(tree.id)
      assert tree.specie != invalid_specie
    end

    test "update_tree/2 with invalid status data returns error changeset" do
      user = insert(:user)
      tree = insert(:tree, user: user)
      invalid_status = :ok

      assert {:error, %Ecto.Changeset{}} = Trees.update_tree(tree, %{status: invalid_status})
      assert tree = Trees.get_tree!(tree.id)
      assert tree.status != invalid_status
    end

    test "delete_tree/1 deletes the tree" do
      tree = insert(:tree)
      assert {:ok, %Tree{}} = Trees.delete_tree(tree)
      assert_raise Ecto.NoResultsError, fn -> Trees.get_tree!(tree.id) end
    end

    test "change_tree/1 returns a tree changeset" do
      tree = build(:tree)
      assert %Ecto.Changeset{} = Trees.change_tree(tree)
    end
  end
end
