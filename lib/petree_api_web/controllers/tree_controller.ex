defmodule PetreeApiWeb.TreeController do
  use PetreeApiWeb, :controller

  alias PetreeApi.Trees
  alias PetreeApi.Trees.Tree

  action_fallback PetreeApiWeb.FallbackController

  def index(conn, _params) do
    trees = Trees.list_trees()
    render(conn, "index.json", trees: trees)
  end

  def create(conn, params) do
    params = extract_location(params)

    with {:ok, %Tree{} = tree} <- Trees.create_tree(params) do
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

  def update(conn, %{"id" => id} = params) do
    params = extract_location(params)

    tree = Trees.get_tree!(id)

    with {:ok, %Tree{} = tree} <- Trees.update_tree(tree, params) do
      render(conn, "show.json", tree: tree)
    end
  end

  defp extract_location(params) do
    if Map.has_key?(params, "lat") or Map.has_key?(params, "lng") do
      if Map.has_key?(params, "lat") and Map.has_key?(params, "lng") do
        %{"lat" => lat, "lng" => lng} = params
        location = %Geo.Point{coordinates: {lat, lng}, srid: 4326}
        Map.put(params, "location", location)
      else
        location = %Geo.Point{coordinates: {nil, nil}, srid: 4326}
        Map.put(params, "location", location)
      end
    else
      params
    end
  end

  def delete(conn, %{"id" => id}) do
    tree = Trees.get_tree!(id)

    with {:ok, %Tree{}} <- Trees.delete_tree(tree) do
      send_resp(conn, :no_content, "")
    end
  end
end
