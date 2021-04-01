defmodule PetreeApiWeb.UserView do
  use PetreeApiWeb, :view
  alias PetreeApiWeb.UserView

  def render("index.json", %{users: users}) do
    %{users: render_many(users, UserView, "user.json")}
  end

  def render("show.json", %{user: user}) do
    render_one(user, UserView, "user.json")
  end

  def render("user.json", %{user: user}) do
    %{
      id: user.id,
      name: user.name,
      nickname: user.nickname,
      email: user.email
    }
  end
end
