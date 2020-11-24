defmodule PetreeApi.Trees.Tree do
  @moduledoc """
  Tree schema
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias PetreeApi.Accounts.User

  schema "trees" do
    field :description, :string
    field :fruitful, :boolean, default: false
    field :lat, :decimal
    field :lng, :decimal
    field :specie, :string
    field :status, Ecto.Enum, values: [:pending, :accepted, :rejected]

    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(tree, attrs) do
    tree
    |> cast(attrs, [:description, :specie, :fruitful, :status, :lat, :lng, :user_id])
    |> validate_required([:description, :specie, :fruitful, :status, :lat, :lng, :user_id])
    |> foreign_key_constraint(:user_id)
  end

  @doc false
  def create_changeset(tree, attrs) do
    tree
    |> cast(attrs, [:description, :specie, :fruitful, :status, :lat, :lng, :user_id])
    |> validate_required([:description, :specie, :fruitful, :status, :lat, :lng, :user_id])
    |> foreign_key_constraint(:user_id)
  end

  @doc false
  def update_changeset(tree, attrs) do
    tree
    |> cast(attrs, [:description, :specie, :fruitful, :status, :lat, :lng, :user_id])
    |> foreign_key_constraint(:user_id)
  end
end
