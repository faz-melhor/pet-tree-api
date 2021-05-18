defmodule PetreeApiWeb.UserController do
  use PetreeApiWeb, :controller

  alias PetreeApi.Accounts
  alias PetreeApi.Accounts.User

  action_fallback PetreeApiWeb.FallbackController

  def index(conn, _params) do
    with {:ok, query, filter_values} <- User.apply_filters(conn),
         users <- Accounts.list_users(query) do
      if Map.get(conn.query_params, "limit") != nil do
        total_count = List.first(Accounts.total_count(query))

        conn
        |> put_resp_header("X-Total-Count", Integer.to_string(total_count))
        |> render("index.json", users: users, meta: filter_values)
      else
        render(conn, "index.json", users: users, meta: filter_values)
      end
    end
  end

  def create(conn, params) do
    with {:ok, %User{}} <- Accounts.create_user(params) do
      conn
      |> send_resp(:created, "")
    end
  end

  def show(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    render(conn, "show.json", user: user)
  end

  def update(conn, %{"id" => id} = params) do
    user = Accounts.get_user!(id)

    with {:ok, %User{}} <- Accounts.update_user(user, params) do
      send_resp(conn, :no_content, "")
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)

    with {:ok, %User{}} <- Accounts.delete_user(user) do
      send_resp(conn, :no_content, "")
    end
  end
end
