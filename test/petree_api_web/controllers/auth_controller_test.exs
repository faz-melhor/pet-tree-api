defmodule PetreeApiWeb.AuthControllerTest do
  use PetreeApiWeb.ConnCase

  import PetreeApi.Factory

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "create token" do
    setup [:create_user]

    test "get token when email and password are valid", %{conn: conn, user: user} do
      conn = post(conn, Routes.auth_path(conn, :create), %{password: "123456", email: user.email})
      assert %{"token" => _token} = json_response(conn, 201)
    end

    test "error when email is invalid", %{conn: conn} do
      conn =
        post(conn, Routes.auth_path(conn, :create), %{
          password: "123456",
          email: "invalid@mail.com"
        })

      assert json_response(conn, 401)["errors"] == %{
               "detail" => "You have entered an invalid username or password"
             }
    end

    test "error when password is invalid", %{conn: conn, user: user} do
      conn =
        post(conn, Routes.auth_path(conn, :create), %{password: "invalid", email: user.email})

      assert json_response(conn, 401)["errors"] == %{
               "detail" => "You have entered an invalid username or password"
             }
    end
  end

  defp create_user(_) do
    %{user: insert(:user)}
  end
end
