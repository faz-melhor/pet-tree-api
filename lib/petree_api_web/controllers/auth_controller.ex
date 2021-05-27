defmodule PetreeApiWeb.AuthController do
  use PetreeApiWeb, :controller

  alias PetreeApi.Auth

  action_fallback PetreeApiWeb.FallbackController

  def create(conn, %{"email" => email, "password" => password}) do
    case Auth.create_token(email, password) do
      {:ok, token, _claims} ->
        conn
        |> put_status(:created)
        |> render("token.json", token: token)

      _ ->
        {:error, :unauthorized}
    end
  end
end
