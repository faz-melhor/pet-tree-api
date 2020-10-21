defmodule PetreeApi.SchemaTest do
  use PetreeApi.DataCase

  alias PetreeApi.Schema

  describe "tree" do
    alias PetreeApi.Schema.Tree

    @valid_attrs %{description: "some description", fruitful: true, lat: 120.5, lng: 120.5, species_id: 42, user_id: 42, status: :pending}
    @update_attrs %{description: "some updated description", fruitful: false, lat: 456.7, lng: 456.7, species_id: 43, user_id: 43, status: :accepted}
    @invalid_attrs %{description: nil, fruitful: nil, lat: nil, lng: nil, species_id: nil, user_id: nil, status: nil}

    def tree_fixture(attrs \\ %{}) do
      {:ok, tree} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Schema.create_tree()

      tree
    end

    test "list_tree/0 returns all tree" do
      tree = tree_fixture()
      assert Schema.list_tree() == [tree]
    end

    test "get_tree!/1 returns the tree with given id" do
      tree = tree_fixture()
      assert Schema.get_tree!(tree.id) == tree
    end

    test "create_tree/1 with valid data creates a tree" do
      assert {:ok, %Tree{} = tree} = Schema.create_tree(@valid_attrs)
      assert tree.description == "some description"
      assert tree.fruitful == true
      assert tree.lat == 120.5
      assert tree.lng == 120.5
      assert tree.species_id == 42
      assert tree.user_id == 42
      assert tree.status == :pending
    end

    test "create_tree/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Schema.create_tree(@invalid_attrs)
    end

    test "update_tree/2 with valid data updates the tree" do
      tree = tree_fixture()
      assert {:ok, %Tree{} = tree} = Schema.update_tree(tree, @update_attrs)
      assert tree.description == "some updated description"
      assert tree.fruitful == false
      assert tree.lat == 456.7
      assert tree.lng == 456.7
      assert tree.species_id == 43
      assert tree.user_id == 43
      assert tree.status == :accepted
    end

    test "update_tree/2 with invalid data returns error changeset" do
      tree = tree_fixture()
      assert {:error, %Ecto.Changeset{}} = Schema.update_tree(tree, @invalid_attrs)
      assert tree == Schema.get_tree!(tree.id)
    end

    test "delete_tree/1 deletes the tree" do
      tree = tree_fixture()
      assert {:ok, %Tree{}} = Schema.delete_tree(tree)
      assert_raise Ecto.NoResultsError, fn -> Schema.get_tree!(tree.id) end
    end

    test "change_tree/1 returns a tree changeset" do
      tree = tree_fixture()
      assert %Ecto.Changeset{} = Schema.change_tree(tree)
    end
  end
end
