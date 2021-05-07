defmodule PetreeApiWeb.TreeControllerTest do
  use PetreeApiWeb.ConnCase

  import PetreeApi.Factory

  alias PetreeApi.Trees.Tree

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    setup [:create_user]

    test "lists all trees", %{conn: conn} do
      conn = get(conn, Routes.tree_path(conn, :index))
      assert json_response(conn, 200)["trees"] == []
    end

    test "lists all trees of a user", %{conn: conn, user: user} do
      conn = get(conn, Routes.tree_path(conn, :index, user.id))
      assert json_response(conn, 200)["trees"] == []
    end

    test "renders error when user does not exist", %{conn: conn} do
      assert_error_sent 404, fn ->
        get(conn, Routes.tree_path(conn, :index, "eb9cb68d-eaf9-4900-a543-4c8877678be4"))
      end
    end

    test "renders errors when user is invalid", %{conn: conn} do
      conn = get(conn, Routes.tree_path(conn, :index, "eb9cb68d-eaf9-4900-a543-4c8877678be"))
      assert response(conn, 404)
    end
  end

  describe "get tree" do
    setup [:create_tree]

    test "renders tree data when tree exist", %{conn: conn, tree: tree} do
      conn = get(conn, Routes.tree_path(conn, :show, tree.id))

      assert %{
               "description" => description,
               "fruitful" => fruitful,
               "id" => id,
               "lat" => lat,
               "lng" => lng,
               "specie" => specie,
               "status" => status,
               "owner" => %{"id" => user_id}
             } = json_response(conn, 200)

      location = %Geo.Point{coordinates: {lat, lng}, srid: 4326}

      assert description == tree.description
      assert fruitful == tree.fruitful
      assert id == tree.id
      assert location == tree.location
      assert specie == tree.specie
      assert String.to_atom(status) == tree.status
      assert tree.user_id == user_id
    end

    test "renders error when tree does not exist", %{conn: conn} do
      assert_error_sent 404, fn ->
        get(conn, Routes.tree_path(conn, :show, "eb9cb68d-eaf9-4900-a543-4c8877678be4"))
      end
    end

    test "renders error when id is invalid", %{conn: conn} do
      conn = get(conn, Routes.tree_path(conn, :show, "eb9cb68d-eaf9-4900-a543-4c8877678be"))
      assert response(conn, 404)
    end
  end

  describe "admin update tree" do
    setup [:create_tree]

    test "renders errors when tree does not exist", %{conn: conn} do
      assert_error_sent 404, fn ->
        patch(conn, Routes.tree_path(conn, :update, "eb9cb68d-eaf9-4900-a543-4c8877678be4"))
      end
    end

    test "renders errors when tree id is invalid", %{conn: conn} do
      conn = patch(conn, Routes.tree_path(conn, :update, "eb9cb68d-eaf9-4900-a543-4c8877678be"))
      assert response(conn, 404)
    end

    test "admin can update tree status", %{conn: conn, tree: tree} do
      new_status = :accepted

      conn = patch(conn, Routes.tree_path(conn, :update, tree.id), %{status: new_status})
      assert response(conn, 204)

      conn = get(conn, Routes.tree_path(conn, :show, tree.id))

      assert %{
               "id" => updated_id,
               "status" => updated_status
             } = json_response(conn, 200)

      assert tree.id == updated_id
      assert new_status == String.to_atom(updated_status)
    end

    test "admin cannot update tree description", %{conn: conn, tree: tree} do
      new_description = "New description"

      conn =
        patch(conn, Routes.tree_path(conn, :update, tree.id), %{description: new_description})

      assert response(conn, 204)

      conn = get(conn, Routes.tree_path(conn, :show, tree.id))

      assert %{
               "id" => updated_id,
               "description" => updated_description
             } = json_response(conn, 200)

      assert tree.id == updated_id
      assert tree.description == updated_description
    end

    test "admin cannot update tree fruitful data", %{conn: conn, tree: tree} do
      new_fruitful = true

      conn = patch(conn, Routes.tree_path(conn, :update, tree.id), %{fruitful: new_fruitful})
      assert response(conn, 204)

      conn = get(conn, Routes.tree_path(conn, :show, tree.id))

      assert %{
               "id" => updated_id,
               "fruitful" => updated_fruitful
             } = json_response(conn, 200)

      assert tree.id == updated_id
      assert tree.fruitful == updated_fruitful
    end

    test "admin cannot update tree location", %{conn: conn, tree: tree} do
      new_latitude = 343_434
      new_longitude = 343_434

      %Geo.Point{coordinates: {lat, lng}} = tree.location

      conn =
        patch(conn, Routes.tree_path(conn, :update, tree.id), %{
          lat: new_latitude,
          lng: new_longitude
        })

      assert response(conn, 204)

      conn = get(conn, Routes.tree_path(conn, :show, tree.id))

      assert %{
               "id" => updated_id,
               "lat" => updated_latitude,
               "lng" => updated_longitude
             } = json_response(conn, 200)

      assert tree.id == updated_id
      assert lat == updated_latitude
      assert lng == updated_longitude
    end

    test "admin cannot update tree specie", %{conn: conn, tree: tree} do
      new_specie = "New Specie Test"

      conn = patch(conn, Routes.tree_path(conn, :update, tree.id), %{specie: new_specie})
      assert response(conn, 204)

      conn = get(conn, Routes.tree_path(conn, :show, tree.id))

      assert %{
               "id" => updated_id,
               "specie" => updated_specie
             } = json_response(conn, 200)

      assert tree.id == updated_id
      assert tree.specie == updated_specie
    end
  end

  describe "user create tree" do
    test "renders tree when data is valid", %{conn: conn} do
      user = insert(:user)
      tree = build(:tree)

      conn =
        post(
          conn,
          Routes.tree_path(conn, :create, user.id),
          tree |> Map.from_struct() |> Map.put("lat", 10) |> Map.put("lng", 10)
        )

      assert response(conn, 201)
    end

    test "renders error when user does not exist", %{conn: conn} do
      tree = build(:tree)

      conn =
        post(
          conn,
          Routes.tree_path(conn, :create, "eb9cb68d-eaf9-4900-a543-4c8877678be4"),
          tree |> Map.from_struct() |> Map.put("lat", 10) |> Map.put("lng", 10)
        )

      assert response(conn, 404)
    end

    test "renders errors when user id is invalid", %{conn: conn} do
      tree = build(:tree)

      conn =
        post(
          conn,
          Routes.tree_path(conn, :create, "eb9cb68d-eaf9-4900-a543-4c8877678be"),
          tree |> Map.from_struct() |> Map.put("lat", 10) |> Map.put("lng", 10)
        )

      assert response(conn, 404)
    end

    test "renders errors when description data is invalid", %{conn: conn} do
      user = insert(:user)
      tree = build(:tree, description: 1)

      conn =
        post(
          conn,
          Routes.tree_path(conn, :create, user.id),
          tree |> Map.from_struct() |> Map.put("lat", 10) |> Map.put("lng", 10)
        )

      assert json_response(conn, 422)["errors"] != %{}
    end

    test "renders errors when description data is nil", %{conn: conn} do
      user = insert(:user)
      tree = build(:tree, description: nil)

      conn =
        post(
          conn,
          Routes.tree_path(conn, :create, user.id),
          tree |> Map.from_struct() |> Map.put("lat", 10) |> Map.put("lng", 10)
        )

      assert json_response(conn, 422)["errors"] != %{}
    end

    test "renders errors when fruitful data is invalid", %{conn: conn} do
      user = insert(:user)
      tree = build(:tree, fruitful: 1)

      conn =
        post(
          conn,
          Routes.tree_path(conn, :create, user.id),
          tree |> Map.from_struct() |> Map.put("lat", 10) |> Map.put("lng", 10)
        )

      assert json_response(conn, 422)["errors"] != %{}
    end

    test "renders errors when fruitful data is nil", %{conn: conn} do
      user = insert(:user)
      tree = build(:tree, fruitful: nil)

      conn =
        post(
          conn,
          Routes.tree_path(conn, :create, user.id),
          tree |> Map.from_struct() |> Map.put("lat", 10) |> Map.put("lng", 10)
        )

      assert json_response(conn, 422)["errors"] != %{}
    end

    test "renders errors when latitude data is invalid", %{conn: conn} do
      user = insert(:user)
      tree = build(:tree)

      conn =
        post(
          conn,
          Routes.tree_path(conn, :create, user.id),
          tree |> Map.from_struct() |> Map.put("lat", "lat") |> Map.put("lng", 10)
        )

      assert json_response(conn, 422)["errors"] != %{}
    end

    test "renders errors when latitude data is nil", %{conn: conn} do
      user = insert(:user)
      tree = build(:tree)

      conn =
        post(
          conn,
          Routes.tree_path(conn, :create, user.id),
          tree |> Map.from_struct() |> Map.put("lng", 10)
        )

      assert json_response(conn, 422)["errors"] != %{}
    end

    test "renders errors when longitude data is invalid", %{conn: conn} do
      user = insert(:user)
      tree = build(:tree)

      conn =
        post(
          conn,
          Routes.tree_path(conn, :create, user.id),
          tree |> Map.from_struct() |> Map.put("lat", 10) |> Map.put("lng", "lng")
        )

      assert json_response(conn, 422)["errors"] != %{}
    end

    test "renders errors when longitude data is nil", %{conn: conn} do
      user = insert(:user)
      tree = build(:tree)

      conn =
        post(
          conn,
          Routes.tree_path(conn, :create, user.id),
          tree |> Map.from_struct() |> Map.put("lat", 10)
        )

      assert json_response(conn, 422)["errors"] != %{}
    end

    test "renders errors when specie data is invalid", %{conn: conn} do
      user = insert(:user)
      tree = build(:tree, specie: 1)

      conn =
        post(
          conn,
          Routes.tree_path(conn, :create, user.id),
          tree |> Map.from_struct() |> Map.put("lat", 10) |> Map.put("lng", 10)
        )

      assert json_response(conn, 422)["errors"] != %{}
    end

    test "renders errors when specie data is nil", %{conn: conn} do
      user = insert(:user)
      tree = build(:tree, specie: nil)

      conn =
        post(
          conn,
          Routes.tree_path(conn, :create, user.id),
          tree |> Map.from_struct() |> Map.put("lat", 10) |> Map.put("lng", 10)
        )

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "get user tree" do
    test "renders tree data when tree exist", %{conn: conn} do
      tree = insert(:tree)

      conn = get(conn, Routes.tree_path(conn, :show, tree.user_id, tree.id))

      assert %{
               "description" => description,
               "fruitful" => fruitful,
               "id" => id,
               "lat" => lat,
               "lng" => lng,
               "specie" => specie,
               "status" => status
             } = json_response(conn, 200)

      location = %Geo.Point{coordinates: {lat, lng}, srid: 4326}

      assert description == tree.description
      assert fruitful == tree.fruitful
      assert id == tree.id
      assert location == tree.location
      assert specie == tree.specie
      assert String.to_atom(status) == tree.status
    end

    test "renders error when tree does not exist", %{conn: conn} do
      tree = insert(:tree)

      assert_error_sent 404, fn ->
        get(
          conn,
          Routes.tree_path(conn, :show, tree.user_id, "eb9cb68d-eaf9-4900-a543-4c8877678be4")
        )
      end
    end

    test "renders error when tree id is invalid", %{conn: conn} do
      tree = insert(:tree)

      conn =
        get(
          conn,
          Routes.tree_path(conn, :show, tree.user_id, "eb9cb68d-eaf9-4900-a543-4c8877678be")
        )

      assert response(conn, 404)
    end

    test "renders error when user does not exist", %{conn: conn} do
      tree = insert(:tree)

      assert_error_sent 404, fn ->
        get(conn, Routes.tree_path(conn, :show, "eb9cb68d-eaf9-4900-a543-4c8877678be4", tree.id))
      end
    end

    test "renders error when user id is invalid", %{conn: conn} do
      tree = insert(:tree)

      conn =
        get(conn, Routes.tree_path(conn, :show, "eb9cb68d-eaf9-4900-a543-4c8877678be", tree.id))

      assert response(conn, 404)
    end
  end

  describe "update tree" do
    setup [:create_tree]

    test "renders error when tree does not exist", %{conn: conn, tree: tree} do
      description = "New Description"

      assert_error_sent 404, fn ->
        patch(
          conn,
          Routes.tree_path(conn, :update, tree.user_id, "eb9cb68d-eaf9-4900-a543-4c8877678be4"),
          %{description: description}
        )
      end
    end

    test "renders error when tree id is not valid", %{conn: conn, tree: tree} do
      description = "New Description"

      conn =
        patch(
          conn,
          Routes.tree_path(conn, :update, tree.user_id, "eb9cb68d-eaf9-4900-a543-4c8877678be"),
          %{description: description}
        )

      assert response(conn, 404)
    end

    test "renders error when user does not exist", %{conn: conn, tree: tree} do
      description = "New Description"

      assert_error_sent 404, fn ->
        patch(
          conn,
          Routes.tree_path(conn, :update, "eb9cb68d-eaf9-4900-a543-4c8877678be4", tree.id),
          %{description: description}
        )
      end
    end

    test "renders error when user id is not valid", %{conn: conn, tree: tree} do
      description = "New Description"

      conn =
        patch(
          conn,
          Routes.tree_path(conn, :update, "eb9cb68d-eaf9-4900-a543-4c8877678be", tree.id),
          %{description: description}
        )

      assert response(conn, 404)
    end

    test "renders tree when description data is valid", %{conn: conn, tree: %Tree{id: id} = tree} do
      description = "New Description"

      conn =
        patch(conn, Routes.tree_path(conn, :update, tree.user_id, id), %{description: description})

      assert response(conn, 204)

      conn = get(conn, Routes.tree_path(conn, :show, tree.user_id, id))

      assert %{
               "id" => updated_id,
               "description" => updated_description
             } = json_response(conn, 200)

      assert id == updated_id
      assert updated_description == description
    end

    test "renders tree when fruitful data is valid", %{conn: conn, tree: %Tree{id: id} = tree} do
      fruitful = false

      conn = patch(conn, Routes.tree_path(conn, :update, tree.user_id, id), %{fruitful: fruitful})
      assert response(conn, 204)

      conn = get(conn, Routes.tree_path(conn, :show, tree.user_id, id))

      assert %{
               "id" => updated_id,
               "fruitful" => updated_fruitful
             } = json_response(conn, 200)

      assert id == updated_id
      assert updated_fruitful == fruitful
    end

    test "renders tree when specie data is valid", %{conn: conn, tree: %Tree{id: id} = tree} do
      specie = "New Specie"

      conn = patch(conn, Routes.tree_path(conn, :update, tree.user_id, id), %{specie: specie})
      assert response(conn, 204)

      conn = get(conn, Routes.tree_path(conn, :show, tree.user_id, id))

      assert %{
               "id" => updated_id,
               "specie" => updated_specie
             } = json_response(conn, 200)

      assert id == updated_id
      assert updated_specie == specie
    end

    test "renders errors when description data is invalid", %{conn: conn, tree: tree} do
      invalid_description = 1

      conn =
        patch(conn, Routes.tree_path(conn, :update, tree.user_id, tree.id), %{
          description: invalid_description
        })

      assert json_response(conn, 422)["errors"] != %{}
    end

    test "renders errors when fruitful data is invalid", %{conn: conn, tree: tree} do
      invalid_fruitful = 1

      conn =
        patch(conn, Routes.tree_path(conn, :update, tree.user_id, tree.id), %{
          fruitful: invalid_fruitful
        })

      assert json_response(conn, 422)["errors"] != %{}
    end

    test "renders errors when specie data is invalid", %{conn: conn, tree: tree} do
      invalid_specie = 1

      conn =
        patch(conn, Routes.tree_path(conn, :update, tree.user_id, tree.id), %{
          specie: invalid_specie
        })

      assert json_response(conn, 422)["errors"] != %{}
    end

    test "user cant update tree status", %{conn: conn, tree: tree} do
      new_status = :accepted

      conn =
        patch(conn, Routes.tree_path(conn, :update, tree.user_id, tree.id), %{status: new_status})

      assert response(conn, 204)

      conn = get(conn, Routes.tree_path(conn, :show, tree.user_id, tree.id))

      assert %{
               "id" => updated_id,
               "status" => updated_status
             } = json_response(conn, 200)

      assert tree.id == updated_id
      assert tree.status == String.to_atom(updated_status)
    end
  end

  describe "delete tree" do
    setup [:create_tree]

    test "deletes chosen tree", %{conn: conn, tree: tree} do
      conn = delete(conn, Routes.tree_path(conn, :delete, tree.user_id, tree.id))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.tree_path(conn, :show, tree.user_id, tree.id))
      end
    end

    test "renders errors when tree does not exist", %{conn: conn, tree: tree} do
      assert_error_sent 404, fn ->
        delete(
          conn,
          Routes.tree_path(conn, :delete, tree.user_id, "eb9cb68d-eaf9-4900-a543-4c8877678be4")
        )
      end
    end

    test "renders errors when tree id is invalid", %{conn: conn, tree: tree} do
      conn =
        delete(
          conn,
          Routes.tree_path(conn, :delete, tree.user_id, "eb9cb68d-eaf9-4900-a543-4c8877678be")
        )

      assert response(conn, 404)
    end

    test "renders errors when user does not exist", %{conn: conn, tree: tree} do
      assert_error_sent 404, fn ->
        delete(
          conn,
          Routes.tree_path(conn, :delete, "eb9cb68d-eaf9-4900-a543-4c8877678be4", tree.id)
        )
      end
    end

    test "renders errors when user id is invalid", %{conn: conn, tree: tree} do
      conn =
        delete(
          conn,
          Routes.tree_path(conn, :delete, "eb9cb68d-eaf9-4900-a543-4c8877678be", tree.id)
        )

      assert response(conn, 404)
    end

    test "renders errors if user is not the tree owner", %{conn: conn, tree: tree} do
      alt_user = insert(:user)

      assert_error_sent 404, fn ->
        delete(conn, Routes.tree_path(conn, :delete, alt_user.id, tree.id))
      end
    end
  end

  defp create_tree(_) do
    user = insert(:user)
    tree = insert(:tree, user: user)

    %{tree: tree}
  end

  defp create_user(_) do
    user = insert(:user)
    %{user: user}
  end
end
