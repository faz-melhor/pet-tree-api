defmodule PetreeApiWeb.TreeController do
  use PetreeApiWeb, :controller

  alias PetreeApi.Trees
  alias PetreeApi.Trees.Tree

  action_fallback PetreeApiWeb.FallbackController

  def index(conn, _params) do
    trees = Trees.list_trees()
    render(conn, "index.json", trees: trees)
  end

  def create(conn, %{"tree" => tree_params}) do
    with {:ok, %Tree{} = tree} <- Trees.create_tree(tree_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.tree_path(conn, :show, tree))
      |> render("show.json", tree: tree)
    end
  end

  def show(conn, %{"id" => id}) do
    tree = Trees.get_tree!(id)
    render(conn, "show.json", tree: tree)
  end

  def update(conn, %{"id" => id, "tree" => tree_params}) do
    tree = Trees.get_tree!(id)

    with {:ok, %Tree{} = tree} <- Trees.update_tree(tree, tree_params) do
      render(conn, "show.json", tree: tree)
    end
  end

  def delete(conn, %{"id" => id}) do
    tree = Trees.get_tree!(id)

    with {:ok, %Tree{}} <- Trees.delete_tree(tree) do
      send_resp(conn, :no_content, "")
    end
  end
end
