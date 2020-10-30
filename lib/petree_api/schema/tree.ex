defmodule PetreeApi.Schema.Tree do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  schema "tree" do
    field :description, :string
    field :fruitful, :boolean, default: false
    field :lat, :float
    field :lng, :float
    field :species_id, :integer
    field :user_id, :integer
    field :status, Ecto.Enum, values: [:pending, :accepted, :rejected]

    timestamps()
  end

  @spec changeset(
          {map, map} | %{:__struct__ => atom | %{__changeset__: map}, optional(atom) => any},
          :invalid | %{optional(:__struct__) => none, optional(atom | binary) => any}
        ) :: Ecto.Changeset.t()
  @doc false
  def changeset(tree, attrs) do
    tree
    |> cast(attrs, [:user_id, :lat, :lng, :description, :species_id, :fruitful, :status])
    |> validate_required([:user_id, :lat, :lng, :description, :species_id, :fruitful, :status])
  end
end
