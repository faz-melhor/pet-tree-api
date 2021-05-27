defmodule PetreeApiWeb.AuthView do
  use PetreeApiWeb, :view

  def render("token.json", %{token: token}) do
    %{token: token}
  end
end
