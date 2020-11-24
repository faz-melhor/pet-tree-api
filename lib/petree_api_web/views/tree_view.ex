defmodule PetreeApiWeb.TreeView do
  use PetreeApiWeb, :view
  alias PetreeApiWeb.TreeView

  def render("index.json", %{trees: trees}) do
    %{data: render_many(trees, TreeView, "tree.json")}
  end

  def render("show.json", %{tree: tree}) do
    %{data: render_one(tree, TreeView, "tree.json")}
  end

  def render("tree.json", %{tree: tree}) do
    %{
      id: tree.id,
      description: tree.description,
      specie: tree.specie,
      fruitful: tree.fruitful,
      status: tree.status,
      lat: tree.lat,
      lng: tree.lng,
      user_id: tree.user_id
    }
  end
end
