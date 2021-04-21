defmodule PetreeApiWeb.UserControllerTest do
  use PetreeApiWeb.ConnCase

  import PetreeApi.Factory

  alias PetreeApi.Accounts.User

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all users", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :index))
      assert json_response(conn, 200)["users"] == []
    end
  end

  describe "create user" do
    test "renders user when data is valid", %{conn: conn} do
      user = build(:user, password: "123456")

      conn = post(conn, Routes.user_path(conn, :create), user |> Map.from_struct())
      assert conn.status == 201
    end

    test "renders errors when name is invalid", %{conn: conn} do
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
      user = build(:user, nickname: nil, password: "123456")
      conn = post(conn, Routes.user_path(conn, :create), user |> Map.from_struct())
      assert json_response(conn, 422)["errors"] == %{"nickname" => ["can't be blank"]}
    end

    test "renders errors when password is invalid", %{conn: conn} do
      user = build(:user)
      conn = post(conn, Routes.user_path(conn, :create), user |> Map.from_struct())
      assert json_response(conn, 422)["errors"] == %{"password" => ["can't be blank"]}
    end
  end

  describe "update user" do
    setup [:create_user]

    test "renders user when name data is valid", %{conn: conn, user: %User{id: id} = user} do
      name = "Janet Smith"

      conn = patch(conn, Routes.user_path(conn, :update, user), %{name: name})
      assert %{"id" => ^id} = json_response(conn, 200)

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
      assert %{"id" => ^id} = json_response(conn, 200)

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
      assert %{"id" => ^id} = json_response(conn, 200)

      conn = get(conn, Routes.user_path(conn, :show, id))

      assert %{
               "id" => updated_id,
               "nickname" => updated_nickname
             } = json_response(conn, 200)

      assert id == updated_id
      assert nickname == updated_nickname
    end

    test "renders user when password data is valid", %{conn: conn, user: %User{id: id} = user} do
      password = "12345"

      conn = patch(conn, Routes.user_path(conn, :update, user), %{password: password})
      assert %{"id" => ^id} = json_response(conn, 200)
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
  end

  defp create_user(_) do
    user = insert(:user)
    %{user: user}
  end
end
