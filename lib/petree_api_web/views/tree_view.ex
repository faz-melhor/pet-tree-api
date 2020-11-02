defmodule PetreeApiWeb.TreeView do
  use PetreeApiWeb, :view
  alias PetreeApiWeb.TreeView

  def render("index.json", %{tree: tree}) do
    %{data: render_many(tree, TreeView, "tree.json")}
  end

  def render("show.json", %{tree: tree}) do
    %{data: render_one(tree, TreeView, "tree.json")}
  end

  def render("tree.json", %{tree: tree}) do
    %{
      id: tree.id,
      user_id: tree.user_id,
      species_id: tree.species_id,
      description: tree.description,
      lat: tree.lat,
      lng: tree.lng,
      status: tree.status,
      fruitful: tree.fruitful
    }
  end
end
