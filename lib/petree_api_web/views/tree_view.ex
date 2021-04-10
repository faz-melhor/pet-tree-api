defmodule PetreeApiWeb.TreeView do
  use PetreeApiWeb, :view
  alias PetreeApiWeb.TreeView

  def render("index.json", %{trees: trees}) do
    %{trees: render_many(trees, TreeView, "tree.json")}
  end

  def render("show.json", %{tree: tree}) do
    render_one(tree, TreeView, "tree.json")
  end

  def render("tree.json", %{tree: tree}) do
    %Geo.Point{coordinates: {lat, lng}} = tree.location

    %{
      id: tree.id,
      description: tree.description,
      specie: tree.specie,
      fruitful: tree.fruitful,
      status: tree.status,
      lat: lat,
      lng: lng,
      user_id: tree.user_id
    }
  end
end
