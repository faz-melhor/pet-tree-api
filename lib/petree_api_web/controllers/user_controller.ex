defmodule PetreeApiWeb.UserController do
  use PetreeApiWeb, :controller

  alias PetreeApi.UserSchema
  alias PetreeApi.UserSchema.User

  action_fallback PetreeApiWeb.FallbackController

  def index(conn, _params) do
    user = UserSchema.list_user()
    render(conn, "index.json", user: user)
  end

  def create(conn, %{"user" => user_params}) do
    with {:ok, %User{} = user} <- UserSchema.create_user(user_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.user_path(conn, :show, user))
      |> render("show.json", user: user)
    end
  end

  def show(conn, %{"id" => id}) do
    user = UserSchema.get_user!(id)
    render(conn, "show.json", user: user)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = UserSchema.get_user!(id)

    with {:ok, %User{} = user} <- UserSchema.update_user(user, user_params) do
      render(conn, "show.json", user: user)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = UserSchema.get_user!(id)

    with {:ok, %User{}} <- UserSchema.delete_user(user) do
      send_resp(conn, :no_content, "")
    end
  end
end
