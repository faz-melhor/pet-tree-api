defmodule PetreeApiWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use PetreeApiWeb, :controller

  # This clause handles errors returned by Ecto's insert/update/delete.
  def call(conn, {:error, %Ecto.Changeset{errors: [{error, {message, _}}]} = changeset}) do
    cond do
      error == :email and message == "has already been taken" ->
        conn
        |> put_status(:conflict)
        |> put_view(PetreeApiWeb.ChangesetView)
        |> render("error.json", changeset: changeset)

      error in [:user_id, :tree_id] and message == "does not exist" ->
        conn
        |> send_resp(404, "")

      true ->
        conn
        |> put_status(:unprocessable_entity)
        |> put_view(PetreeApiWeb.ChangesetView)
        |> render("error.json", changeset: changeset)
    end
  end

  def call(conn, {:error, %Ecto.Changeset{errors: _} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(PetreeApiWeb.ChangesetView)
    |> render("error.json", changeset: changeset)
  end

  def call(conn, {:error, :unauthorized}) do
    conn
    |> put_status(:unauthorized)
    |> json(%{errors: %{detail: "You have entered an invalid username or password"}})
  end

  def call(conn, {:error, message}) do
    conn
    |> put_status(:bad_request)
    |> put_view(PetreeApiWeb.ErrorView)
    |> render("400.json", message: message)
  end
end
