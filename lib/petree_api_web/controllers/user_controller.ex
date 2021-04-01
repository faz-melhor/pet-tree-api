defmodule PetreeApiWeb.UserController do
  use PetreeApiWeb, :controller

  alias PetreeApi.Accounts
  alias PetreeApi.Accounts.User

  action_fallback PetreeApiWeb.FallbackController

  def index(conn, _params) do
    users = Accounts.list_users()
    render(conn, "index.json", users: users)
  end

  def create(conn, params) do
    with {:ok, %User{}} <- Accounts.create_user(params) do
      conn
      |> send_resp(201, "")
    end
  end

  def show(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    render(conn, "show.json", user: user)
  end

  def update(conn, params) do
    %{"id" => id} = params

    user = Accounts.get_user!(id)

    with {:ok, %User{} = user} <- Accounts.update_user(user, params) do
      render(conn, "show.json", user: user)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)

    with {:ok, %User{}} <- Accounts.delete_user(user) do
      send_resp(conn, :no_content, "")
    end
  end
end
