defmodule PetreeApiWeb.TreeControllerTest do
  use PetreeApiWeb.ConnCase

  import PetreeApi.Factory
  import PetreeApiWeb.Auth.Guardian

  alias PetreeApi.Trees.Tree

  setup %{conn: conn} do
    user = insert(:user)
    {:ok, token, _} = encode_and_sign(%{id: user.id})

    conn =
      conn
      |> put_req_header("accept", "application/json")
      |> put_req_header("authorization", "Bearer " <> token)

    {:ok, conn: conn}
  end

  describe "index" do
    setup [:create_user]
    setup [:create_trees]

    test "lists all trees", %{conn: conn} do
      conn = get(conn, Routes.tree_path(conn, :index))
      assert is_list(json_response(conn, 200)["trees"])
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

    test "renders trees according to limit filter", %{conn: conn} do
      query_params = "?limit=2&offset=0"
      conn = get(conn, Routes.tree_path(conn, :index) <> query_params)

      assert length(json_response(conn, 200)["trees"]) == 2
    end

    test "renders trees according to limit and offset filters", %{conn: conn, trees: trees} do
      query_params = "?limit=2&offset=2"
      conn = get(conn, Routes.tree_path(conn, :index) <> query_params)
      tree = List.first(json_response(conn, 200)["trees"])

      assert Map.get(tree, "id") == Enum.at(trees, 2).id
    end

    test "check trees X-Total-Count key header value", %{conn: conn} do
      query_params = "?limit=2&offset=2"
      conn = get(conn, Routes.tree_path(conn, :index) <> query_params)

      assert List.first(get_resp_header(conn, "X-Total-Count")) == "4"
    end

    test "renders trees with a specific status", %{conn: conn} do
      query_params = "?status=accepted"
      conn = get(conn, Routes.tree_path(conn, :index) <> query_params)

      assert length(json_response(conn, 200)["trees"]) == 2
    end

    test "renders trees within a specific range (1000m)", %{conn: conn} do
      query_params = "?lat=-34.582795056619794&lng=-58.40823471344631&radius=1000"
      conn = get(conn, Routes.tree_path(conn, :index) <> query_params)

      assert length(json_response(conn, 200)["trees"]) == 4
    end

    test "renders trees within a specific range (800m)", %{conn: conn} do
      query_params = "?lat=-34.582795056619794&lng=-58.40823471344631&radius=800"
      conn = get(conn, Routes.tree_path(conn, :index) <> query_params)

      assert length(json_response(conn, 200)["trees"]) == 2
    end

    test "renders error when limit filter is invalid (trees)", %{conn: conn} do
      query_params = "?limit=asdf&offset=0"
      conn = get(conn, Routes.tree_path(conn, :index) <> query_params)

      assert json_response(conn, 400)["errors"] == %{
               "detail" => "Unable to cast \"asdf\" to integer"
             }
    end

    test "renders error when offset filter is invalid (trees)", %{conn: conn} do
      query_params = "?limit=2&offset=asdf"
      conn = get(conn, Routes.tree_path(conn, :index) <> query_params)

      assert json_response(conn, 400)["errors"] == %{
               "detail" => "Unable to cast \"asdf\" to integer"
             }
    end

    test "renders error when status filter is invalid (trees)", %{conn: conn} do
      query_params = "?status=asdf"
      conn = get(conn, Routes.tree_path(conn, :index) <> query_params)

      assert json_response(conn, 400)["errors"] == %{
               "detail" =>
                 "Unable to cast \"asdf\" to atom with options: [:accepted, :pending, :rejected]"
             }
    end

    test "renders error when lat filter is invalid (trees)", %{conn: conn} do
      query_params = "?lat=asdf&lng=-58.40823471344631&radius=800"
      conn = get(conn, Routes.tree_path(conn, :index) <> query_params)

      assert json_response(conn, 400)["errors"] == %{
               "detail" => "Unable to cast \"asdf\" to float"
             }
    end

    test "renders error when lng filter is invalid (trees)", %{conn: conn} do
      query_params = "?lat=-34.582795056619794&lng=asdf&radius=800"
      conn = get(conn, Routes.tree_path(conn, :index) <> query_params)

      assert json_response(conn, 400)["errors"] == %{
               "detail" => "Unable to cast \"asdf\" to float"
             }
    end

    test "renders error when radius filter is invalid (trees)", %{conn: conn} do
      query_params = "?lat=-34.582795056619794&lng=-58.40823471344631&radius=asdf"
      conn = get(conn, Routes.tree_path(conn, :index) <> query_params)

      assert json_response(conn, 400)["errors"] == %{
               "detail" => "Unable to cast \"asdf\" to float"
             }
    end

    test "renders error when lat filter is missing (trees)", %{conn: conn} do
      query_params = "?lng=-58.40823471344631&radius=800"
      conn = get(conn, Routes.tree_path(conn, :index) <> query_params)

      assert json_response(conn, 400)["errors"] == %{
               "detail" => "Please, check if lat, lng or radius is missing"
             }
    end

    test "renders error when lng filter is missing (trees)", %{conn: conn} do
      query_params = "?lat=-34.582795056619794&radius=800"
      conn = get(conn, Routes.tree_path(conn, :index) <> query_params)

      assert json_response(conn, 400)["errors"] == %{
               "detail" => "Please, check if lat, lng or radius is missing"
             }
    end

    test "renders error when radius filter is missing (trees)", %{conn: conn} do
      query_params = "?lat=-34.582795056619794&lng=-58.40823471344631"
      conn = get(conn, Routes.tree_path(conn, :index) <> query_params)

      assert json_response(conn, 400)["errors"] == %{
               "detail" => "Please, check if lat, lng or radius is missing"
             }
    end

    test "renders user trees according to limit filter", %{conn: conn, trees: trees} do
      user_id = List.first(trees).user_id
      query_params = "?limit=2&offset=0"
      conn = get(conn, Routes.tree_path(conn, :index, user_id) <> query_params)

      assert length(json_response(conn, 200)["trees"]) == 2
    end

    test "renders user trees according to limit and offset filters", %{conn: conn, trees: trees} do
      user_id = List.first(trees).user_id
      query_params = "?limit=2&offset=2"
      conn = get(conn, Routes.tree_path(conn, :index, user_id) <> query_params)
      tree = List.first(json_response(conn, 200)["trees"])

      assert Map.get(tree, "id") == Enum.at(trees, 2).id
    end

    test "check user trees X-Total-Count key header value", %{conn: conn, trees: trees} do
      user_id = List.first(trees).user_id
      query_params = "?limit=2&offset=2"
      conn = get(conn, Routes.tree_path(conn, :index, user_id) <> query_params)

      assert List.first(get_resp_header(conn, "X-Total-Count")) == "4"
    end

    test "renders user trees with a specific status", %{conn: conn, trees: trees} do
      user_id = List.first(trees).user_id
      query_params = "?status=accepted"
      conn = get(conn, Routes.tree_path(conn, :index, user_id) <> query_params)

      assert length(json_response(conn, 200)["trees"]) == 2
    end

    test "renders user trees within a specific range (1000m)", %{conn: conn, trees: trees} do
      user_id = List.first(trees).user_id
      query_params = "?lat=-34.582795056619794&lng=-58.40823471344631&radius=1000"
      conn = get(conn, Routes.tree_path(conn, :index, user_id) <> query_params)

      assert length(json_response(conn, 200)["trees"]) == 4
    end

    test "renders user trees within a specific range (800m)", %{conn: conn, trees: trees} do
      user_id = List.first(trees).user_id
      query_params = "?lat=-34.582795056619794&lng=-58.40823471344631&radius=800"
      conn = get(conn, Routes.tree_path(conn, :index, user_id) <> query_params)

      assert length(json_response(conn, 200)["trees"]) == 2
    end

    test "renders error when limit filter is invalid (user trees)", %{conn: conn, trees: trees} do
      user_id = List.first(trees).user_id
      query_params = "?limit=asdf&offset=0"
      conn = get(conn, Routes.tree_path(conn, :index, user_id) <> query_params)

      assert json_response(conn, 400)["errors"] == %{
               "detail" => "Unable to cast \"asdf\" to integer"
             }
    end

    test "renders error when offset filter is invalid (user trees)", %{conn: conn, trees: trees} do
      user_id = List.first(trees).user_id
      query_params = "?limit=2&offset=asdf"
      conn = get(conn, Routes.tree_path(conn, :index, user_id) <> query_params)

      assert json_response(conn, 400)["errors"] == %{
               "detail" => "Unable to cast \"asdf\" to integer"
             }
    end

    test "renders error when status filter is invalid (user trees)", %{conn: conn, trees: trees} do
      user_id = List.first(trees).user_id
      query_params = "?status=asdf"
      conn = get(conn, Routes.tree_path(conn, :index, user_id) <> query_params)

      assert json_response(conn, 400)["errors"] == %{
               "detail" =>
                 "Unable to cast \"asdf\" to atom with options: [:accepted, :pending, :rejected]"
             }
    end

    test "renders error when lat filter is invalid (user trees)", %{conn: conn, trees: trees} do
      user_id = List.first(trees).user_id
      query_params = "?lat=asdf&lng=-58.40823471344631&radius=800"
      conn = get(conn, Routes.tree_path(conn, :index, user_id) <> query_params)

      assert json_response(conn, 400)["errors"] == %{
               "detail" => "Unable to cast \"asdf\" to float"
             }
    end

    test "renders error when lng filter is invalid (user trees)", %{conn: conn, trees: trees} do
      user_id = List.first(trees).user_id
      query_params = "?lat=-34.582795056619794&lng=asdf&radius=800"
      conn = get(conn, Routes.tree_path(conn, :index, user_id) <> query_params)

      assert json_response(conn, 400)["errors"] == %{
               "detail" => "Unable to cast \"asdf\" to float"
             }
    end

    test "renders error when radius filter is invalid (user trees)", %{conn: conn, trees: trees} do
      user_id = List.first(trees).user_id
      query_params = "?lat=-34.582795056619794&lng=-58.40823471344631&radius=asdf"
      conn = get(conn, Routes.tree_path(conn, :index, user_id) <> query_params)

      assert json_response(conn, 400)["errors"] == %{
               "detail" => "Unable to cast \"asdf\" to float"
             }
    end

    test "renders error when lat filter is missing (user trees)", %{conn: conn, trees: trees} do
      user_id = List.first(trees).user_id
      query_params = "?lng=-58.40823471344631&radius=800"
      conn = get(conn, Routes.tree_path(conn, :index, user_id) <> query_params)

      assert json_response(conn, 400)["errors"] == %{
               "detail" => "Please, check if lat, lng or radius is missing"
             }
    end

    test "renders error when lng filter is missing (user trees)", %{conn: conn, trees: trees} do
      user_id = List.first(trees).user_id
      query_params = "?lat=-34.582795056619794&radius=800"
      conn = get(conn, Routes.tree_path(conn, :index, user_id) <> query_params)

      assert json_response(conn, 400)["errors"] == %{
               "detail" => "Please, check if lat, lng or radius is missing"
             }
    end

    test "renders error when radius filter is missing (user trees)", %{conn: conn, trees: trees} do
      user_id = List.first(trees).user_id
      query_params = "?lat=-34.582795056619794&lng=-58.40823471344631"
      conn = get(conn, Routes.tree_path(conn, :index, user_id) <> query_params)

      assert json_response(conn, 400)["errors"] == %{
               "detail" => "Please, check if lat, lng or radius is missing"
             }
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
    setup [:create_admin]

    test "renders errors when tree does not exist", %{conn: conn} do
      assert_error_sent 404, fn ->
        patch(conn, Routes.tree_path(conn, :update, "eb9cb68d-eaf9-4900-a543-4c8877678be4"))
      end
    end

    test "renders errors when tree id is invalid", %{conn: conn} do
      conn = patch(conn, Routes.tree_path(conn, :update, "eb9cb68d-eaf9-4900-a543-4c8877678be"))
      assert response(conn, 404)
    end

    test "admin can update tree status", %{conn: conn, tree: tree, admin: admin} do
      new_status = :accepted
      {:ok, token, _} = encode_and_sign(%{id: admin.id})

      conn =
        conn
        |> put_req_header("authorization", "Bearer " <> token)
        |> patch(Routes.tree_path(conn, :update, tree.id), %{status: new_status})

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

      assert json_response(conn, 403)["errors"] == %{"detail" => "Forbidden"}
    end

    test "admin cannot update tree fruitful data", %{conn: conn, tree: tree} do
      new_fruitful = true

      conn = patch(conn, Routes.tree_path(conn, :update, tree.id), %{fruitful: new_fruitful})
      assert json_response(conn, 403)["errors"] == %{"detail" => "Forbidden"}
    end

    test "admin cannot update tree location", %{conn: conn, tree: tree} do
      new_latitude = 343_434
      new_longitude = 343_434

      conn =
        patch(conn, Routes.tree_path(conn, :update, tree.id), %{
          lat: new_latitude,
          lng: new_longitude
        })

      assert json_response(conn, 403)["errors"] == %{"detail" => "Forbidden"}
    end

    test "admin cannot update tree specie", %{conn: conn, tree: tree} do
      new_specie = "New Specie Test"

      conn = patch(conn, Routes.tree_path(conn, :update, tree.id), %{specie: new_specie})
      assert json_response(conn, 403)["errors"] == %{"detail" => "Forbidden"}
    end
  end

  describe "user create tree" do
    test "renders tree when data is valid", %{conn: conn} do
      user = insert(:user)
      tree = build(:tree)

      {:ok, token, _} = encode_and_sign(%{id: user.id})

      conn =
        conn
        |> put_req_header("authorization", "Bearer " <> token)
        |> post(
          Routes.tree_path(conn, :create, user.id),
          tree |> Map.from_struct() |> Map.put("lat", 10) |> Map.put("lng", 10)
        )

      assert response(conn, 201)
    end

    test "renders errors when description data is invalid", %{conn: conn} do
      user = insert(:user)
      tree = build(:tree, description: 1)

      {:ok, token, _} = encode_and_sign(%{id: user.id})

      conn =
        conn
        |> put_req_header("authorization", "Bearer " <> token)
        |> post(
          Routes.tree_path(conn, :create, user.id),
          tree |> Map.from_struct() |> Map.put("lat", 10) |> Map.put("lng", 10)
        )

      assert json_response(conn, 422)["errors"] != %{}
    end

    test "renders errors when description data is nil", %{conn: conn} do
      user = insert(:user)
      tree = build(:tree, description: nil)

      {:ok, token, _} = encode_and_sign(%{id: user.id})

      conn =
        conn
        |> put_req_header("authorization", "Bearer " <> token)
        |> post(
          Routes.tree_path(conn, :create, user.id),
          tree |> Map.from_struct() |> Map.put("lat", 10) |> Map.put("lng", 10)
        )

      assert json_response(conn, 422)["errors"] != %{}
    end

    test "renders errors when fruitful data is invalid", %{conn: conn} do
      user = insert(:user)
      tree = build(:tree, fruitful: 1)

      {:ok, token, _} = encode_and_sign(%{id: user.id})

      conn =
        conn
        |> put_req_header("authorization", "Bearer " <> token)
        |> post(
          Routes.tree_path(conn, :create, user.id),
          tree |> Map.from_struct() |> Map.put("lat", 10) |> Map.put("lng", 10)
        )

      assert json_response(conn, 422)["errors"] != %{}
    end

    test "renders errors when fruitful data is nil", %{conn: conn} do
      user = insert(:user)
      tree = build(:tree, fruitful: nil)

      {:ok, token, _} = encode_and_sign(%{id: user.id})

      conn =
        conn
        |> put_req_header("authorization", "Bearer " <> token)
        |> post(
          Routes.tree_path(conn, :create, user.id),
          tree |> Map.from_struct() |> Map.put("lat", 10) |> Map.put("lng", 10)
        )

      assert json_response(conn, 422)["errors"] != %{}
    end

    test "renders errors when latitude data is invalid", %{conn: conn} do
      user = insert(:user)
      tree = build(:tree)

      {:ok, token, _} = encode_and_sign(%{id: user.id})

      conn =
        conn
        |> put_req_header("authorization", "Bearer " <> token)
        |> post(
          Routes.tree_path(conn, :create, user.id),
          tree |> Map.from_struct() |> Map.put("lat", "lat") |> Map.put("lng", 10)
        )

      assert json_response(conn, 422)["errors"] != %{}
    end

    test "renders errors when latitude data is nil", %{conn: conn} do
      user = insert(:user)
      tree = build(:tree)

      {:ok, token, _} = encode_and_sign(%{id: user.id})

      conn =
        conn
        |> put_req_header("authorization", "Bearer " <> token)
        |> post(
          Routes.tree_path(conn, :create, user.id),
          tree |> Map.from_struct() |> Map.put("lng", 10)
        )

      assert json_response(conn, 422)["errors"] != %{}
    end

    test "renders errors when longitude data is invalid", %{conn: conn} do
      user = insert(:user)
      tree = build(:tree)

      {:ok, token, _} = encode_and_sign(%{id: user.id})

      conn =
        conn
        |> put_req_header("authorization", "Bearer " <> token)
        |> post(
          Routes.tree_path(conn, :create, user.id),
          tree |> Map.from_struct() |> Map.put("lat", 10) |> Map.put("lng", "lng")
        )

      assert json_response(conn, 422)["errors"] != %{}
    end

    test "renders errors when longitude data is nil", %{conn: conn} do
      user = insert(:user)
      tree = build(:tree)

      {:ok, token, _} = encode_and_sign(%{id: user.id})

      conn =
        conn
        |> put_req_header("authorization", "Bearer " <> token)
        |> post(
          Routes.tree_path(conn, :create, user.id),
          tree |> Map.from_struct() |> Map.put("lat", 10)
        )

      assert json_response(conn, 422)["errors"] != %{}
    end

    test "renders errors when specie data is invalid", %{conn: conn} do
      user = insert(:user)
      tree = build(:tree, specie: 1)

      {:ok, token, _} = encode_and_sign(%{id: user.id})

      conn =
        conn
        |> put_req_header("authorization", "Bearer " <> token)
        |> post(
          Routes.tree_path(conn, :create, user.id),
          tree |> Map.from_struct() |> Map.put("lat", 10) |> Map.put("lng", 10)
        )

      assert json_response(conn, 422)["errors"] != %{}
    end

    test "renders errors when specie data is nil", %{conn: conn} do
      user = insert(:user)
      tree = build(:tree, specie: nil)

      {:ok, token, _} = encode_and_sign(%{id: user.id})

      conn =
        conn
        |> put_req_header("authorization", "Bearer " <> token)
        |> post(
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

      {:ok, token, _} = encode_and_sign(%{id: tree.user_id})

      conn =
        conn
        |> put_req_header("authorization", "Bearer " <> token)
        |> patch(Routes.tree_path(conn, :update, tree.user_id, id), %{description: description})

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

      {:ok, token, _} = encode_and_sign(%{id: tree.user_id})

      conn =
        conn
        |> put_req_header("authorization", "Bearer " <> token)
        |> patch(Routes.tree_path(conn, :update, tree.user_id, id), %{fruitful: fruitful})

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

      {:ok, token, _} = encode_and_sign(%{id: tree.user_id})

      conn =
        conn
        |> put_req_header("authorization", "Bearer " <> token)
        |> patch(Routes.tree_path(conn, :update, tree.user_id, id), %{specie: specie})

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

      {:ok, token, _} = encode_and_sign(%{id: tree.user_id})

      conn =
        conn
        |> put_req_header("authorization", "Bearer " <> token)
        |> patch(Routes.tree_path(conn, :update, tree.user_id, tree.id), %{
          description: invalid_description
        })

      assert json_response(conn, 422)["errors"] != %{}
    end

    test "renders errors when fruitful data is invalid", %{conn: conn, tree: tree} do
      invalid_fruitful = 1

      {:ok, token, _} = encode_and_sign(%{id: tree.user_id})

      conn =
        conn
        |> put_req_header("authorization", "Bearer " <> token)
        |> patch(Routes.tree_path(conn, :update, tree.user_id, tree.id), %{
          fruitful: invalid_fruitful
        })

      assert json_response(conn, 422)["errors"] != %{}
    end

    test "renders errors when specie data is invalid", %{conn: conn, tree: tree} do
      invalid_specie = 1

      {:ok, token, _} = encode_and_sign(%{id: tree.user_id})

      conn =
        conn
        |> put_req_header("authorization", "Bearer " <> token)
        |> patch(Routes.tree_path(conn, :update, tree.user_id, tree.id), %{
          specie: invalid_specie
        })

      assert json_response(conn, 422)["errors"] != %{}
    end

    test "user cant update tree status", %{conn: conn, tree: tree} do
      new_status = :accepted

      {:ok, token, _} = encode_and_sign(%{id: tree.user_id})

      conn =
        conn
        |> put_req_header("authorization", "Bearer " <> token)
        |> patch(Routes.tree_path(conn, :update, tree.user_id, tree.id), %{status: new_status})

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
      {:ok, token, _} = encode_and_sign(%{id: tree.user_id})

      conn =
        conn
        |> put_req_header("authorization", "Bearer " <> token)
        |> delete(Routes.tree_path(conn, :delete, tree.user_id, tree.id))

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

  defp create_admin(_) do
    admin = insert(:user, roles: ["user", "admin"])
    %{admin: admin}
  end

  defp create_trees(_) do
    user = insert(:user)
    location1 = %Geo.Point{coordinates: {-34.576084203197084, -58.40969063273531}, srid: 4326}
    location2 = %Geo.Point{coordinates: {-34.58201006934206, -58.40084546048161}, srid: 4326}

    trees =
      insert_list(2, :tree, user: user, status: :accepted, location: location1) ++
        insert_list(2, :tree, user: user, location: location2)

    %{trees: trees}
  end
end
