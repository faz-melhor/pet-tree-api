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
      assert json_response(conn, 200)["trees"] == []
    end
  end

  describe "create tree" do
    test "renders tree when data is valid", %{conn: conn} do
      user = insert(:user)
      tree = build(:tree, user_id: user.id)

      conn =
        post(
          conn,
          Routes.tree_path(conn, :create),
          tree |> Map.from_struct() |> Map.put("lat", 10) |> Map.put("lng", 10)
        )

      assert %{"id" => id} = json_response(conn, 201)

      %{
        description: description,
        fruitful: fruitful,
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
             } = json_response(conn, 200)

      assert id == created_id
      assert description == created_description
      assert fruitful == created_fruitful
      assert 10 == created_lat
      assert 10 == created_lng
      assert specie == created_specie
      assert status == String.to_existing_atom(created_status)
      assert user.id == created_user_id
    end

    test "renders errors when user id is invalid", %{conn: conn} do
      tree = build(:tree, user_id: 999)
      conn = post(conn, Routes.tree_path(conn, :create), tree |> Map.from_struct())
      assert json_response(conn, 422)["errors"] != %{}
    end

    test "renders errors when description data is invalid", %{conn: conn} do
      user = insert(:user)
      tree = build(:tree, user_id: user.id, description: 1)

      conn = post(conn, Routes.tree_path(conn, :create), tree |> Map.from_struct())
      assert json_response(conn, 422)["errors"] != %{}
    end

    test "renders errors when fruitful data is invalid", %{conn: conn} do
      user = insert(:user)
      tree = build(:tree, user_id: user.id, fruitful: 1)

      conn = post(conn, Routes.tree_path(conn, :create), tree |> Map.from_struct())
      assert json_response(conn, 422)["errors"] != %{}
    end

    test "renders errors when latitude data is invalid", %{conn: conn} do
      user = insert(:user)
      tree = build(:tree, user_id: user.id)

      conn =
        post(
          conn,
          Routes.tree_path(conn, :create),
          tree |> Map.from_struct() |> Map.put("lat", "lat") |> Map.put("lng", 10)
        )

      assert json_response(conn, 422)["errors"] != %{}
    end

    test "renders errors when longitude data is invalid", %{conn: conn} do
      user = insert(:user)
      tree = build(:tree, user_id: user.id)

      conn =
        post(
          conn,
          Routes.tree_path(conn, :create),
          tree |> Map.from_struct() |> Map.put("lat", 10) |> Map.put("lng", "lng")
        )

      assert json_response(conn, 422)["errors"] != %{}
    end

    test "renders errors when specie data is invalid", %{conn: conn} do
      user = insert(:user)
      tree = build(:tree, user_id: user.id, specie: 1)

      conn = post(conn, Routes.tree_path(conn, :create), tree |> Map.from_struct())
      assert json_response(conn, 422)["errors"] != %{}
    end

    test "renders errors when status data is invalid", %{conn: conn} do
      user = insert(:user)
      tree = build(:tree, user_id: user.id, status: :ok)

      conn = post(conn, Routes.tree_path(conn, :create), tree |> Map.from_struct())
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update tree" do
    setup [:create_tree]

    test "renders tree when description data is valid", %{conn: conn, tree: %Tree{id: id} = tree} do
      description = "New Description"

      conn = put(conn, Routes.tree_path(conn, :update, tree), %{description: description})
      assert %{"id" => ^id} = json_response(conn, 200)

      conn = get(conn, Routes.tree_path(conn, :show, id))

      assert %{
               "id" => updated_id,
               "description" => updated_description
             } = json_response(conn, 200)

      assert id == updated_id
      assert updated_description == description
    end

    test "renders tree when fruitful data is valid", %{conn: conn, tree: %Tree{id: id} = tree} do
      fruitful = false

      conn = put(conn, Routes.tree_path(conn, :update, tree), %{fruitful: fruitful})
      assert %{"id" => ^id} = json_response(conn, 200)

      conn = get(conn, Routes.tree_path(conn, :show, id))

      assert %{
               "id" => updated_id,
               "fruitful" => updated_fruitful
             } = json_response(conn, 200)

      assert id == updated_id
      assert updated_fruitful == fruitful
    end

    test "renders tree when latitude and longitude data are valid", %{
      conn: conn,
      tree: %Tree{id: id} = tree
    } do
      lat = -34.57613278928747
      lng = -58.40964771739279

      conn =
        put(conn, Routes.tree_path(conn, :update, tree), %{
          location: %Geo.Point{coordinates: {lat, lng}, srid: 4326}
        })

      assert %{"id" => ^id} = json_response(conn, 200)

      conn = get(conn, Routes.tree_path(conn, :show, id))

      assert %{
               "id" => updated_id,
               "lat" => updated_latitude,
               "lng" => updated_longitude
             } = json_response(conn, 200)

      assert id == updated_id
      assert updated_latitude == lat
      assert updated_longitude == lng
    end

    test "renders tree when specie data is valid", %{conn: conn, tree: %Tree{id: id} = tree} do
      specie = "New Specie"

      conn = put(conn, Routes.tree_path(conn, :update, tree), %{specie: specie})
      assert %{"id" => ^id} = json_response(conn, 200)

      conn = get(conn, Routes.tree_path(conn, :show, id))

      assert %{
               "id" => updated_id,
               "specie" => updated_specie
             } = json_response(conn, 200)

      assert id == updated_id
      assert updated_specie == specie
    end

    test "renders tree when status data is valid", %{conn: conn, tree: %Tree{id: id} = tree} do
      status = :accepted

      conn = put(conn, Routes.tree_path(conn, :update, tree), %{status: status})
      assert %{"id" => ^id} = json_response(conn, 200)

      conn = get(conn, Routes.tree_path(conn, :show, id))

      assert %{
               "id" => updated_id,
               "status" => updated_status
             } = json_response(conn, 200)

      assert id == updated_id
      assert String.to_existing_atom(updated_status) == status
    end

    test "renders tree when user id is valid", %{conn: conn, tree: %Tree{id: id} = tree} do
      %{id: user_id} = insert(:user)

      conn = put(conn, Routes.tree_path(conn, :update, tree), %{user_id: user_id})
      assert %{"id" => ^id} = json_response(conn, 200)

      conn = get(conn, Routes.tree_path(conn, :show, id))

      assert %{
               "id" => updated_id,
               "user_id" => updated_user_id
             } = json_response(conn, 200)

      assert id == updated_id
      assert updated_user_id == user_id
    end

    test "renders errors when description data is invalid", %{conn: conn, tree: tree} do
      invalid_description = 1

      conn = put(conn, Routes.tree_path(conn, :update, tree), %{description: invalid_description})

      assert json_response(conn, 422)["errors"] != %{}
    end

    test "renders errors when fruitful data is invalid", %{conn: conn, tree: tree} do
      invalid_fruitful = 1

      conn = put(conn, Routes.tree_path(conn, :update, tree), %{fruitful: invalid_fruitful})
      assert json_response(conn, 422)["errors"] != %{}
    end

    test "renders errors when latitude data is invalid", %{conn: conn, tree: tree} do
      invalid_latitude = "lat"

      conn = put(conn, Routes.tree_path(conn, :update, tree), %{lat: invalid_latitude})
      assert json_response(conn, 422)["errors"] != %{}
    end

    test "renders errors when longitude data is invalid", %{conn: conn, tree: tree} do
      invalid_longitude = "lng"

      conn = put(conn, Routes.tree_path(conn, :update, tree), %{lng: invalid_longitude})
      assert json_response(conn, 422)["errors"] != %{}
    end

    test "renders errors when specie data is invalid", %{conn: conn, tree: tree} do
      invalid_specie = 1

      conn = put(conn, Routes.tree_path(conn, :update, tree), %{specie: invalid_specie})
      assert json_response(conn, 422)["errors"] != %{}
    end

    test "renders errors when status data is invalid", %{conn: conn, tree: tree} do
      invalid_status = :ok

      conn = put(conn, Routes.tree_path(conn, :update, tree), %{status: invalid_status})
      assert json_response(conn, 422)["errors"] != %{}
    end

    test "renders errors when user id is invalid", %{conn: conn, tree: tree} do
      invalid_user_id = nil

      conn = put(conn, Routes.tree_path(conn, :update, tree), %{user_id: invalid_user_id})
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
