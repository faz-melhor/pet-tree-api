defmodule PetreeApiWeb.UserController do
  use PetreeApiWeb, :controller

  alias PetreeApi.Accounts
  alias PetreeApi.Accounts.User
  alias PetreeApiWeb.Auth.Guardian

  action_fallback PetreeApiWeb.FallbackController

  def index(conn, _params) do
    current_user = Guardian.Plug.current_resource(conn)

    with :ok <- Bodyguard.permit(Accounts, :get_all_users, current_user),
         {:ok, query, filter_values} <- User.apply_filters(conn),
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
    current_user = Guardian.Plug.current_resource(conn)

    with :ok <- Bodyguard.permit(Accounts, :get_user, id, current_user) do
      user = Accounts.get_user!(id)
      render(conn, "show.json", user: user)
    end
  end

  def update(conn, %{"id" => id} = params) do
    current_user = Guardian.Plug.current_resource(conn)
    user = Accounts.get_user!(id)

    if Map.has_key?(params, "roles") do
      roles = Map.take(params, ["roles"])

      roles_update(user, current_user, roles, conn)
    else
      user_update(user, current_user, params, conn)
    end
  end

  defp roles_update(user, current_user, roles, conn) do
    with :ok <- Bodyguard.permit(Accounts, :update_user_roles, current_user),
         {:ok, %User{}} <- Accounts.roles_update(user, roles) do
      send_resp(conn, :no_content, "")
    end
  end

  defp user_update(user, current_user, params, conn) do
    with :ok <- Bodyguard.permit(Accounts, :update_user, current_user.id, user),
         {:ok, %User{}} <- Accounts.update_user(user, params) do
      send_resp(conn, :no_content, "")
    end
  end

  def delete(conn, %{"id" => id}) do
    current_user = Guardian.Plug.current_resource(conn)
    user = Accounts.get_user!(id)

    with :ok <- Bodyguard.permit(Accounts, :delete_user, current_user.id, user),
         {:ok, %User{}} <- Accounts.delete_user(user) do
      send_resp(conn, :no_content, "")
    end
  end
end
