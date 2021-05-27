defmodule PetreeApiWeb.UserControllerTest do
  use PetreeApiWeb.ConnCase

  import PetreeApi.Factory
  import PetreeApiWeb.Auth.Guardian

  alias PetreeApi.Accounts.User

  setup %{conn: conn} do
    {:ok, token, _} = encode_and_sign(%{id: "user_id"})

    conn =
      conn
      |> put_req_header("accept", "application/json")
      |> put_req_header("authorization", "Bearer " <> token)

    {:ok, conn: conn}
  end

  describe "index" do
    setup [:create_users]

    test "lists all users", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :index))
      assert is_list(json_response(conn, 200)["users"])
    end

    test "renders users according to limit filter", %{conn: conn} do
      query_params = "?limit=2&offset=0"
      conn = get(conn, Routes.user_path(conn, :index) <> query_params)
      assert length(json_response(conn, 200)["users"]) == 2
    end

    test "renders users according to limit and offset filters", %{conn: conn, users: users} do
      query_params = "?limit=2&offset=2"
      conn = get(conn, Routes.user_path(conn, :index) <> query_params)
      user = List.first(json_response(conn, 200)["users"])

      assert Map.get(user, "id") == Enum.at(users, 2).id
    end

    test "check X-Total-Count header value", %{conn: conn} do
      query_params = "?limit=2&offset=2"
      conn = get(conn, Routes.user_path(conn, :index) <> query_params)

      assert List.first(get_resp_header(conn, "X-Total-Count")) == "4"
    end
  end

  describe "create user" do
    test "renders user when data is valid", %{conn: conn} do
      user = build(:user, password: "123456")

      conn = post(conn, Routes.user_path(conn, :create), user |> Map.from_struct())
      assert conn.status == 201
    end

    test "renders errors when name is invalid", %{conn: conn} do
      user = build(:user, name: 1234, password: "123456")
      conn = post(conn, Routes.user_path(conn, :create), user |> Map.from_struct())
      assert json_response(conn, 422)["errors"] == %{"name" => ["is invalid"]}
    end

    test "renders errors when name is nil", %{conn: conn} do
      user = build(:user, name: nil, password: "123456")
      conn = post(conn, Routes.user_path(conn, :create), user |> Map.from_struct())
      assert json_response(conn, 422)["errors"] == %{"name" => ["can't be blank"]}
    end

    test "renders errors when email is invalid", %{conn: conn} do
      user = build(:user, email: "email", password: "123456")
      conn = post(conn, Routes.user_path(conn, :create), user |> Map.from_struct())
      assert json_response(conn, 422)["errors"] == %{"email" => ["has invalid format"]}
    end

    test "renders errors when email is blank", %{conn: conn} do
      user = build(:user, email: "", password: "123456")
      conn = post(conn, Routes.user_path(conn, :create), user |> Map.from_struct())
      assert json_response(conn, 422)["errors"] == %{"email" => ["can't be blank"]}
    end

    test "renders errors when email already exist", %{conn: conn} do
      user = insert(:user, password: "123456")
      conn = post(conn, Routes.user_path(conn, :create), user |> Map.from_struct())
      assert json_response(conn, 409)["errors"] == %{"email" => ["has already been taken"]}
    end

    test "renders errors when nickname is invalid", %{conn: conn} do
      user = build(:user, nickname: 12_345, password: "123456")
      conn = post(conn, Routes.user_path(conn, :create), user |> Map.from_struct())
      assert json_response(conn, 422)["errors"] == %{"nickname" => ["is invalid"]}
    end

    test "renders errors when nickname is nil", %{conn: conn} do
      user = build(:user, nickname: nil, password: "123456")
      conn = post(conn, Routes.user_path(conn, :create), user |> Map.from_struct())
      assert json_response(conn, 422)["errors"] == %{"nickname" => ["can't be blank"]}
    end

    test "renders errors when password is invalid", %{conn: conn} do
      user = build(:user, password: 12_345)
      conn = post(conn, Routes.user_path(conn, :create), user |> Map.from_struct())
      assert json_response(conn, 422)["errors"] == %{"password" => ["is invalid"]}
    end

    test "renders errors when password is nil", %{conn: conn} do
      user = build(:user)
      conn = post(conn, Routes.user_path(conn, :create), user |> Map.from_struct())
      assert json_response(conn, 422)["errors"] == %{"password" => ["can't be blank"]}
    end
  end

  describe "get user" do
    setup [:create_user]

    test "renders user data when user exist", %{conn: conn, user: user} do
      conn = get(conn, Routes.user_path(conn, :show, user.id))

      assert %{
               "name" => user_name,
               "nickname" => user_nickname,
               "email" => user_email
             } = json_response(conn, 200)

      assert user_name == user.name
      assert user_nickname == user.nickname
      assert user_email == user.email
    end

    test "error when user does not exist", %{conn: conn} do
      assert_error_sent 404, fn ->
        get(conn, Routes.user_path(conn, :show, "eb9cb68d-eaf9-4900-a543-4c8877678be4"))
      end
    end

    test "error when id is invalid", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :show, "eb9cb68d-eaf9-4900-a543-4c8877678be"))
      assert response(conn, 404)
    end
  end

  describe "update user" do
    setup [:create_user]

    test "renders user when name data is valid", %{conn: conn, user: %User{id: id} = user} do
      name = "Janet Smith"

      conn = patch(conn, Routes.user_path(conn, :update, user), %{name: name})
      assert response(conn, 204)

      conn = get(conn, Routes.user_path(conn, :show, id))

      assert %{
               "id" => updated_id,
               "name" => updated_name
             } = json_response(conn, 200)

      assert id == updated_id
      assert name == updated_name
    end

    test "renders user when email data is valid", %{conn: conn, user: %User{id: id} = user} do
      email = "emailtest@mail.com"

      conn = patch(conn, Routes.user_path(conn, :update, user), %{email: email})
      assert response(conn, 204)

      conn = get(conn, Routes.user_path(conn, :show, id))

      assert %{
               "id" => updated_id,
               "email" => updated_email
             } = json_response(conn, 200)

      assert id == updated_id
      assert email == updated_email
    end

    test "renders user when nickname data is valid", %{conn: conn, user: %User{id: id} = user} do
      nickname = "Janet"

      conn = patch(conn, Routes.user_path(conn, :update, user), %{nickname: nickname})
      assert response(conn, 204)

      conn = get(conn, Routes.user_path(conn, :show, id))

      assert %{
               "id" => updated_id,
               "nickname" => updated_nickname
             } = json_response(conn, 200)

      assert id == updated_id
      assert nickname == updated_nickname
    end

    test "renders user when password data is valid", %{conn: conn, user: user} do
      password = "12345"

      conn = patch(conn, Routes.user_path(conn, :update, user), %{password: password})
      assert response(conn, 204)
    end

    test "renders errors when name data is invalid", %{conn: conn, user: user} do
      name = 1

      conn = patch(conn, Routes.user_path(conn, :update, user), %{name: name})
      assert json_response(conn, 422)["errors"] != %{}
    end

    test "renders errors when email data is invalid", %{conn: conn, user: user} do
      email = "email"

      conn = patch(conn, Routes.user_path(conn, :update, user), %{email: email})
      assert json_response(conn, 422)["errors"] != %{}
    end

    test "renders errors when nickname data is invalid", %{conn: conn, user: user} do
      nickname = 1

      conn = patch(conn, Routes.user_path(conn, :update, user), %{nickname: nickname})
      assert json_response(conn, 422)["errors"] != %{}
    end

    test "renders errors when password data is invalid", %{conn: conn, user: user} do
      password = 1

      conn = patch(conn, Routes.user_path(conn, :update, user), %{password: password})
      assert json_response(conn, 422)["errors"] != %{}
    end

    test "renders errors when user does not exist", %{conn: conn} do
      nickname = "testupdate"

      assert_error_sent 404, fn ->
        patch(conn, Routes.user_path(conn, :update, "eb9cb68d-eaf9-4900-a543-4c8877678be4"), %{
          nickname: nickname
        })
      end
    end

    test "renders errors when user is invalid", %{conn: conn} do
      nickname = "testupdate"

      conn =
        patch(conn, Routes.user_path(conn, :update, "eb9cb68d-eaf9-4900-a543-4c8877678be"), %{
          nickname: nickname
        })

      assert response(conn, 404)
    end
  end

  describe "delete user" do
    setup [:create_user]

    test "deletes chosen user", %{conn: conn, user: user} do
      conn = delete(conn, Routes.user_path(conn, :delete, user))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.user_path(conn, :show, user))
      end
    end

    test "renders errors when user does not exist", %{conn: conn} do
      assert_error_sent 404, fn ->
        delete(conn, Routes.user_path(conn, :delete, "eb9cb68d-eaf9-4900-a543-4c8877678be4"))
      end
    end

    test "renders errors when user id is invalid", %{conn: conn} do
      conn = delete(conn, Routes.user_path(conn, :delete, "eb9cb68d-eaf9-4900-a543-4c8877678be"))
      assert response(conn, 404)
    end
  end

  defp create_user(_) do
    user = insert(:user)
    %{user: user}
  end

  defp create_users(_) do
    users = insert_list(4, :user)
    %{users: users}
  end
end
