defmodule PetreeApiWeb.TreeControllerTest do
  use PetreeApiWeb.ConnCase

  alias PetreeApi.Schema
  alias PetreeApi.Schema.Tree

  @create_attrs %{
    description: "some description",
    fruitful: true,
    inserted_at: ~N[2010-04-17 14:00:00],
    lat: 120.5,
    lng: 120.5,
    species_id: 42,
    updated_at: ~N[2010-04-17 14:00:00],
    user_id: 42
  }
  @update_attrs %{
    description: "some updated description",
    fruitful: false,
    inserted_at: ~N[2011-05-18 15:01:01],
    lat: 456.7,
    lng: 456.7,
    species_id: 43,
    updated_at: ~N[2011-05-18 15:01:01],
    user_id: 43
  }
  @invalid_attrs %{description: nil, fruitful: nil, inserted_at: nil, lat: nil, lng: nil, species_id: nil, updated_at: nil, user_id: nil}

  def fixture(:tree) do
    {:ok, tree} = Schema.create_tree(@create_attrs)
    tree
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all tree", %{conn: conn} do
      conn = get(conn, Routes.tree_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create tree" do
    test "renders tree when data is valid", %{conn: conn} do
      conn = post(conn, Routes.tree_path(conn, :create), tree: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.tree_path(conn, :show, id))

      assert %{
               "id" => id,
               "description" => "some description",
               "fruitful" => true,
               "inserted_at" => "2010-04-17T14:00:00",
               "lat" => 120.5,
               "lng" => 120.5,
               "species_id" => 42,
               "updated_at" => "2010-04-17T14:00:00",
               "user_id" => 42
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.tree_path(conn, :create), tree: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update tree" do
    setup [:create_tree]

    test "renders tree when data is valid", %{conn: conn, tree: %Tree{id: id} = tree} do
      conn = put(conn, Routes.tree_path(conn, :update, tree), tree: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.tree_path(conn, :show, id))

      assert %{
               "id" => id,
               "description" => "some updated description",
               "fruitful" => false,
               "inserted_at" => "2011-05-18T15:01:01",
               "lat" => 456.7,
               "lng" => 456.7,
               "species_id" => 43,
               "updated_at" => "2011-05-18T15:01:01",
               "user_id" => 43
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, tree: tree} do
      conn = put(conn, Routes.tree_path(conn, :update, tree), tree: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete tree" do
    setup [:create_tree]

    test "deletes chosen tree", %{conn: conn, tree: tree} do
      conn = delete(conn, Routes.tree_path(conn, :delete, tree))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.tree_path(conn, :show, tree))
      end
    end
  end

  defp create_tree(_) do
    tree = fixture(:tree)
    %{tree: tree}
  end
end
