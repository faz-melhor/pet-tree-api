defmodule PetreeApiWeb.TreeController do
  use PetreeApiWeb, :controller

  alias PetreeApi.Trees
  alias PetreeApi.Trees.Tree
  alias PetreeApiWeb.Auth.Guardian

  action_fallback PetreeApiWeb.FallbackController

  def index(conn, %{"id" => user_id}) do
    with {:ok, query, filter_values} <- Tree.apply_filters(conn),
         trees <- Trees.list_trees(query, user_id),
         do: build_response(conn, query, filter_values, trees)
  end

  def index(conn, _params) do
    with {:ok, query, filter_values} <- Tree.apply_filters(conn),
         trees <- Trees.list_trees(query),
         do: build_response(conn, query, filter_values, trees)
  end

  def create(%Plug.Conn{path_params: %{"id" => id}} = conn, params) do
    current_user = Guardian.Plug.current_resource(conn)

    params = extract_location(params)
    params = Map.put(params, "user_id", id)

    with :ok <- Bodyguard.permit(Trees, :create_tree, id, current_user),
         {:ok, %Tree{}} <- Trees.create_tree(params) do
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
    current_user = Guardian.Plug.current_resource(conn)

    params = Map.take(params, ["description", "specie", "fruitful"])

    tree = Trees.get_tree!(tree_id, user_id)

    with :ok <- Bodyguard.permit(Trees, :update_tree, current_user, tree),
         {:ok, %Tree{}} <- Trees.update_tree(tree, params) do
      send_resp(conn, :no_content, "")
    end
  end

  def update(conn, %{"id" => id} = params) do
    current_user = Guardian.Plug.current_resource(conn)

    params = Map.take(params, ["status"])

    tree = Trees.get_tree!(id)

    with :ok <- Bodyguard.permit(Trees, :update_tree_status, current_user),
         {:ok, %Tree{}} <- Trees.update_tree(tree, params) do
      send_resp(conn, :no_content, "")
    end
  end

  def delete(conn, %{"user_id" => user_id, "tree_id" => tree_id}) do
    current_user = Guardian.Plug.current_resource(conn)

    tree = Trees.get_tree!(tree_id, user_id)

    with :ok <- Bodyguard.permit(Trees, :delete_tree, current_user, tree),
         {:ok, %Tree{}} <- Trees.delete_tree(tree) do
      send_resp(conn, :no_content, "")
    end
  end

  defp build_response(conn, query, filter_values, trees) do
    if Map.get(conn.query_params, "limit") != nil do
      total_count = List.first(Trees.total_count(query))

      conn
      |> put_resp_header("X-Total-Count", Integer.to_string(total_count))
      |> render("index.json", trees: trees, meta: filter_values)
    else
      render(conn, "index.json", trees: trees, meta: filter_values)
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
end
