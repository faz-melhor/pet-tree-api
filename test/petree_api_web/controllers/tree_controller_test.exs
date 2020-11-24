defmodule PetreeApiWeb.TreeControllerTest do
  use PetreeApiWeb.ConnCase

  import PetreeApi.Factory

  alias PetreeApi.Trees.Tree

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all trees", %{conn: conn} do
      conn = get(conn, Routes.tree_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create tree" do
    test "renders tree when data is valid", %{conn: conn} do
      user = insert(:user)
      tree = build(:tree, user_id: user.id)

      conn = post(conn, Routes.tree_path(conn, :create), tree: tree |> Map.from_struct())
      assert %{"id" => id} = json_response(conn, 201)["data"]

      %{
        description: description,
        fruitful: fruitful,
        lat: lat,
        lng: lng,
        specie: specie,
        status: status
      } = tree

      conn = get(conn, Routes.tree_path(conn, :show, id))

      assert %{
               "id" => created_id,
               "description" => created_description,
               "fruitful" => created_fruitful,
               "lat" => created_lat,
               "lng" => created_lng,
               "specie" => created_specie,
               "status" => created_status,
               "user_id" => created_user_id
             } = json_response(conn, 200)["data"]

      assert id == created_id
      assert description == created_description
      assert fruitful == created_fruitful
      assert lat == Decimal.new(created_lat)
      assert lng == Decimal.new(created_lng)
      assert specie == created_specie
      assert status == String.to_existing_atom(created_status)
      assert user.id == created_user_id
    end

    test "renders errors when user id is invalid", %{conn: conn} do
      tree = build(:tree, user_id: 999)
      conn = post(conn, Routes.tree_path(conn, :create), tree: tree |> Map.from_struct())
      assert json_response(conn, 422)["errors"] != %{}
    end

    test "renders errors when description data is invalid", %{conn: conn} do
      user = insert(:user)
      tree = build(:tree, user: user, description: 1)

      conn = post(conn, Routes.tree_path(conn, :create), tree: tree |> Map.from_struct())
      assert json_response(conn, 422)["errors"] != %{}
    end

    test "renders errors when fruitful data is invalid", %{conn: conn} do
      user = insert(:user)
      tree = build(:tree, user: user, fruitful: 1)

      conn = post(conn, Routes.tree_path(conn, :create), tree: tree |> Map.from_struct())
      assert json_response(conn, 422)["errors"] != %{}
    end

    test "renders errors when latitude data is invalid", %{conn: conn} do
      user = insert(:user)
      tree = build(:tree, user: user, lat: "lat")

      conn = post(conn, Routes.tree_path(conn, :create), tree: tree |> Map.from_struct())
      assert json_response(conn, 422)["errors"] != %{}
    end

    test "renders errors when longitude data is invalid", %{conn: conn} do
      user = insert(:user)
      tree = build(:tree, user: user, lng: "lng")

      conn = post(conn, Routes.tree_path(conn, :create), tree: tree |> Map.from_struct())
      assert json_response(conn, 422)["errors"] != %{}
    end

    test "renders errors when specie data is invalid", %{conn: conn} do
      user = insert(:user)
      tree = build(:tree, user: user, specie: 1)

      conn = post(conn, Routes.tree_path(conn, :create), tree: tree |> Map.from_struct())
      assert json_response(conn, 422)["errors"] != %{}
    end

    test "renders errors when status data is invalid", %{conn: conn} do
      user = insert(:user)
      tree = build(:tree, user: user, status: :ok)

      conn = post(conn, Routes.tree_path(conn, :create), tree: tree |> Map.from_struct())
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update tree" do
    setup [:create_tree]

    test "renders tree when description data is valid", %{conn: conn, tree: %Tree{id: id} = tree} do
      description = "New Description"

      conn = put(conn, Routes.tree_path(conn, :update, tree), tree: %{description: description})
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.tree_path(conn, :show, id))

      assert %{
               "id" => updated_id,
               "description" => updated_description
             } = json_response(conn, 200)["data"]

      assert id == updated_id
      assert updated_description == description
    end

    test "renders tree when fruitful data is valid", %{conn: conn, tree: %Tree{id: id} = tree} do
      fruitful = false

      conn = put(conn, Routes.tree_path(conn, :update, tree), tree: %{fruitful: fruitful})
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.tree_path(conn, :show, id))

      assert %{
               "id" => updated_id,
               "fruitful" => updated_fruitful
             } = json_response(conn, 200)["data"]

      assert id == updated_id
      assert updated_fruitful == fruitful
    end

    test "renders tree when latitude data is valid", %{conn: conn, tree: %Tree{id: id} = tree} do
      latitude = Decimal.new("10.0")

      conn = put(conn, Routes.tree_path(conn, :update, tree), tree: %{lat: latitude})
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.tree_path(conn, :show, id))

      assert %{
               "id" => updated_id,
               "lat" => updated_latitude
             } = json_response(conn, 200)["data"]

      assert id == updated_id
      assert Decimal.new(updated_latitude) == latitude
    end

    test "renders tree when longitude data is valid", %{conn: conn, tree: %Tree{id: id} = tree} do
      longitude = Decimal.new("10.0")

      conn = put(conn, Routes.tree_path(conn, :update, tree), tree: %{lng: longitude})
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.tree_path(conn, :show, id))

      assert %{
               "id" => updated_id,
               "lng" => updated_longitude
             } = json_response(conn, 200)["data"]

      assert id == updated_id
      assert Decimal.new(updated_longitude) == longitude
    end

    test "renders tree when specie data is valid", %{conn: conn, tree: %Tree{id: id} = tree} do
      specie = "New Specie"

      conn = put(conn, Routes.tree_path(conn, :update, tree), tree: %{specie: specie})
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.tree_path(conn, :show, id))

      assert %{
               "id" => updated_id,
               "specie" => updated_specie
             } = json_response(conn, 200)["data"]

      assert id == updated_id
      assert updated_specie == specie
    end

    test "renders tree when status data is valid", %{conn: conn, tree: %Tree{id: id} = tree} do
      status = :accepted

      conn = put(conn, Routes.tree_path(conn, :update, tree), tree: %{status: status})
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.tree_path(conn, :show, id))

      assert %{
               "id" => updated_id,
               "status" => updated_status
             } = json_response(conn, 200)["data"]

      assert id == updated_id
      assert String.to_existing_atom(updated_status) == status
    end

    test "renders tree when user id is valid", %{conn: conn, tree: %Tree{id: id} = tree} do
      %{id: user_id} = insert(:user)

      conn = put(conn, Routes.tree_path(conn, :update, tree), tree: %{user_id: user_id})
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.tree_path(conn, :show, id))

      assert %{
               "id" => updated_id,
               "user_id" => updated_user_id
             } = json_response(conn, 200)["data"]

      assert id == updated_id
      assert updated_user_id == user_id
    end

    test "renders errors when description data is invalid", %{conn: conn, tree: tree} do
      invalid_description = 1

      conn =
        put(conn, Routes.tree_path(conn, :update, tree), tree: %{description: invalid_description})

      assert json_response(conn, 422)["errors"] != %{}
    end

    test "renders errors when fruitful data is invalid", %{conn: conn, tree: tree} do
      invalid_fruitful = 1

      conn = put(conn, Routes.tree_path(conn, :update, tree), tree: %{fruitful: invalid_fruitful})
      assert json_response(conn, 422)["errors"] != %{}
    end

    test "renders errors when latitude data is invalid", %{conn: conn, tree: tree} do
      invalid_latitude = "lat"

      conn = put(conn, Routes.tree_path(conn, :update, tree), tree: %{lat: invalid_latitude})
      assert json_response(conn, 422)["errors"] != %{}
    end

    test "renders errors when longitude data is invalid", %{conn: conn, tree: tree} do
      invalid_longitude = "lng"

      conn = put(conn, Routes.tree_path(conn, :update, tree), tree: %{lng: invalid_longitude})
      assert json_response(conn, 422)["errors"] != %{}
    end

    test "renders errors when specie data is invalid", %{conn: conn, tree: tree} do
      invalid_specie = 1

      conn = put(conn, Routes.tree_path(conn, :update, tree), tree: %{specie: invalid_specie})
      assert json_response(conn, 422)["errors"] != %{}
    end

    test "renders errors when status data is invalid", %{conn: conn, tree: tree} do
      invalid_status = :ok

      conn = put(conn, Routes.tree_path(conn, :update, tree), tree: %{status: invalid_status})
      assert json_response(conn, 422)["errors"] != %{}
    end

    test "renders errors when user id is invalid", %{conn: conn, tree: tree} do
      invalid_user_id = nil

      conn = put(conn, Routes.tree_path(conn, :update, tree), tree: %{user_id: invalid_user_id})
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
    user = insert(:user)
    tree = insert(:tree, user: user)

    %{tree: tree}
  end
end
