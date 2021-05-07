defmodule PetreeApi.Trees do
  @moduledoc """
  The Trees context.
  """

  import Ecto.Query, warn: false
  alias PetreeApi.Repo

  alias PetreeApi.Accounts.User
  alias PetreeApi.Trees.Tree

  @doc """
  Returns the list of trees of a user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> list_trees!(user_id)
      [%Tree{}, ...]

      iex> list_trees!(user_id)
      ** (Ecto.NoResultsError)

  """
  def list_trees!(user_id) do
    User
    |> Repo.get!(user_id)
    |> Repo.preload(:trees)
    |> Map.get(:trees)
  end

  @doc """
  Returns the list of trees.

  ## Examples

      iex> list_trees()
      [%Tree{}, ...]

  """
  def list_trees do
    Tree
    |> Repo.all()
    |> Repo.preload(:user)
  end

  @doc """
  Gets a single tree from a specific user.

  Raises `Ecto.NoResultsError` if the Tree does not exist.

  ## Examples

      iex> get_tree!(123, 456)
      %Tree{}

      iex> get_tree!(456, 456)
      ** (Ecto.NoResultsError)

  """

  def get_tree!(tree_id, user_id) do
    Repo.one!(from t in Tree, where: t.id == ^tree_id and t.user_id == ^user_id)
  end

  @doc """
  Gets a single tree

  Raises `Ecto.NoResultsError` if the Tree does not exist.

  ## Examples

      iex> get_tree!(123)
      %Tree{}

      iex> get_tree!(456)
      ** (Ecto.NoResultsError)

  """
  def get_tree!(id), do: Tree |> Repo.get!(id) |> Repo.preload(:user)

  @doc """
  Creates a tree.

  ## Examples

      iex> create_tree(%{field: value})
      {:ok, %Tree{}}

      iex> create_tree(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_tree(attrs \\ %{}) do
    %Tree{}
    |> Tree.create_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a tree.

  ## Examples

      iex> update_tree(tree, %{field: new_value})
      {:ok, %Tree{}}

      iex> update_tree(tree, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_tree(%Tree{} = tree, attrs) do
    tree
    |> Tree.update_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a tree.

  ## Examples

      iex> delete_tree(tree)
      {:ok, %Tree{}}

      iex> delete_tree(tree)
      {:error, %Ecto.Changeset{}}

  """
  def delete_tree(%Tree{} = tree) do
    Repo.delete(tree)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking tree changes.

  ## Examples

      iex> change_tree(tree)
      %Ecto.Changeset{data: %Tree{}}

  """
  def change_tree(%Tree{} = tree, attrs \\ %{}) do
    Tree.update_changeset(tree, attrs)
  end
end
