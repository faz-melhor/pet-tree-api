defmodule PetreeApi.Trees.Tree do
  @moduledoc """
  Tree schema
  """
  use PetreeApi.Schema
  import Ecto.Changeset

  alias PetreeApi.Accounts.User

  schema "trees" do
    field :description, :string
    field :fruitful, :boolean, default: false
    field :location, Geo.PostGIS.Geometry
    field :specie, :string
    field :status, Ecto.Enum, values: [:pending, :accepted, :rejected]

    belongs_to :user, User

    timestamps()
  end

  @doc false
  def create_changeset(tree, attrs) do
    tree
    |> cast(attrs, [:description, :specie, :fruitful, :location, :user_id])
    |> validate_required([:description, :specie, :fruitful, :location, :user_id])
    |> validate_user_id()
    |> validate_location(:location)
    |> put_change(:status, :pending)
    |> foreign_key_constraint(:user_id)
  end

  @doc false
  def update_changeset(tree, attrs) do
    tree
    |> cast(attrs, [:description, :specie, :fruitful, :status, :location, :user_id])
    |> validate_location(:location)
    |> validate_user_id()
    |> foreign_key_constraint(:user_id)
  end

  @doc """
  Validate user id to prevent nil value or invalid UUID
  """
  def validate_user_id(changeset) do
    user_id = get_field(changeset, :user_id)

    case user_id do
      nil ->
        add_error(changeset, :user_id, "can't be blank", validation: :required)

      _ ->
        case Ecto.UUID.cast(user_id) do
          :error -> add_error(changeset, :user_id, "invalid UUID")
          _ -> changeset
        end
    end
  end

  @doc """
  Validate longitude and latitude inside Geo.Point object
  """
  def validate_location(changeset, field) do
    validate_change(changeset, field, fn _, value ->
      %Geo.Point{coordinates: {lat, lng}} = value

      case is_number(lat) and is_number(lng) do
        true ->
          []

        false ->
          [
            location:
              {"latitude and/or longitude are invalid",
               [type: :number, validation: "validate_location"]}
          ]
      end
    end)
  end
end
