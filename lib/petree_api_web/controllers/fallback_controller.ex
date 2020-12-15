defmodule PetreeApiWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use PetreeApiWeb, :controller

  # This clause handles errors returned by Ecto's insert/update/delete.
  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    if should_render_as_conflict?(changeset) do
      conn
      |> put_status(:conflict)
      |> put_view(PetreeApiWeb.ChangesetView)
      |> render("error.json", changeset: changeset)
    else
      conn
      |> put_status(:unprocessable_entity)
      |> put_view(PetreeApiWeb.ChangesetView)
      |> render("error.json", changeset: changeset)
    end
  end

  # This clause is an example of how to handle resources that cannot be found.
  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(PetreeApiWeb.ErrorView)
    |> render(:"404")
  end

  defp should_render_as_conflict?(%Ecto.Changeset{errors: errors}) do
    Enum.any?(errors, &error_is_conflict?(&1))
  end

  defp should_render_as_conflict?(%Ecto.Changeset{}), do: false

  defp error_is_conflict?({:email, {"has already been taken", _}}), do: true
  defp error_is_conflict?(_), do: false
end
