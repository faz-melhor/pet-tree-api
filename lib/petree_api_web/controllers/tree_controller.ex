defmodule PetreeApiWeb.TreeController do
  use PetreeApiWeb, :controller

  alias PetreeApi.Trees
  alias PetreeApi.Trees.Tree

  action_fallback PetreeApiWeb.FallbackController

  def index(conn, %{"id" => user_id}) do
    trees = Trees.list_trees!(user_id)
    render(conn, "index.json", trees: trees)
  end

  def index(conn, _params) do
    trees = Trees.list_trees()
    render(conn, "index.json", trees: trees)
  end

  def create(%Plug.Conn{path_params: %{"id" => id}} = conn, params) do
    params = extract_location(params)
    params = Map.put(params, "user_id", id)

    with {:ok, %Tree{}} <- Trees.create_tree(params) do
      conn
      |> send_resp(:created, "")
    end
  end

  def show(conn, %{"user_id" => user_id, "tree_id" => tree_id}) do
    tree = Trees.get_tree!(tree_id, user_id)
    render(conn, "show.json", tree: tree)
  end

  def show(conn, %{"id" => id}) do
    tree = Trees.get_tree!(id)
    render(conn, "show.json", tree: tree)
  end

  def update(conn, %{"user_id" => user_id, "tree_id" => tree_id} = params) do
    params = Map.take(params, ["description", "specie", "fruitful"])

    tree = Trees.get_tree!(tree_id, user_id)

    with {:ok, %Tree{}} <- Trees.update_tree(tree, params) do
      send_resp(conn, :no_content, "")
    end
  end

  def update(conn, %{"id" => id} = params) do
    params = Map.take(params, ["status"])

    tree = Trees.get_tree!(id)

    with {:ok, %Tree{}} <- Trees.update_tree(tree, params) do
      send_resp(conn, :no_content, "")
    end
  end

  defp extract_location(params) do
    if Map.has_key?(params, "lat") and Map.has_key?(params, "lng") do
      %{"lat" => lat, "lng" => lng} = params
      location = %Geo.Point{coordinates: {lat, lng}, srid: 4326}
      Map.put(params, "location", location)
    else
      location = %Geo.Point{coordinates: {nil, nil}, srid: 4326}
      Map.put(params, "location", location)
    end
  end

  def delete(conn, %{"user_id" => user_id, "tree_id" => tree_id}) do
    tree = Trees.get_tree!(tree_id, user_id)

    with {:ok, %Tree{}} <- Trees.delete_tree(tree) do
      send_resp(conn, :no_content, "")
    end
  end
end
