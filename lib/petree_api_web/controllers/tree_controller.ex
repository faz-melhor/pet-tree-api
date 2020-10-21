defmodule PetreeApiWeb.TreeController do
  use PetreeApiWeb, :controller

  alias PetreeApi.Schema
  alias PetreeApi.Schema.Tree

  action_fallback PetreeApiWeb.FallbackController

  def index(conn, _params) do
    tree = Schema.list_tree()
    render(conn, "index.json", tree: tree)
  end

  def create(conn, %{"tree" => tree_params}) do
    with {:ok, %Tree{} = tree} <- Schema.create_tree(tree_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.tree_path(conn, :show, tree))
      |> render("show.json", tree: tree)
    end
  end

  def show(conn, %{"id" => id}) do
    tree = Schema.get_tree!(id)
    render(conn, "show.json", tree: tree)
  end

  def update(conn, %{"id" => id, "tree" => tree_params}) do
    tree = Schema.get_tree!(id)

    with {:ok, %Tree{} = tree} <- Schema.update_tree(tree, tree_params) do
      render(conn, "show.json", tree: tree)
    end
  end

  def delete(conn, %{"id" => id}) do
    tree = Schema.get_tree!(id)

    with {:ok, %Tree{}} <- Schema.delete_tree(tree) do
      send_resp(conn, :no_content, "")
    end
  end
end
