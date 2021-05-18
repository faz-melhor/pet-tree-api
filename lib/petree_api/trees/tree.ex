defmodule PetreeApi.Trees.Tree do
  @moduledoc """
  Tree schema
  """
  use PetreeApi.Schema
  use Filterable.Phoenix.Model

  import Ecto.Changeset
  import Ecto.Query, warn: false
  import Geo.PostGIS

  alias PetreeApi.Accounts.User

  filterable do
    limitable()
    field :status, cast: {:atom, [:accepted, :pending, :rejected]}

    @options param: [:lat, :lng, :radius], cast: :float
    filter location(query, %{lat: lat, lng: lng, radius: radius}, _conn) do
      cond do
        is_nil(lat) and is_nil(lng) and is_nil(radius) ->
          query

        is_nil(lat) or is_nil(lng) or is_nil(radius) ->
          {:error, "Please, check if lat, lng or radius is missing"}

        true ->
          query
          |> where(
            [q],
            st_dwithin_in_meters(st_set_srid(st_point(^lat, ^lng), 4326), q.location, ^radius)
          )
      end
    end
  end

  schema "trees" do
    field :description, :string
    field :fruitful, :boolean
    field :location, Geo.PostGIS.Geometry
    field :specie, :string
    field :status, Ecto.Enum, values: [:pending, :accepted, :rejected], default: :pending

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
  Validate user id to prevent nil value
  """
  def validate_user_id(changeset) do
    user_id = get_field(changeset, :user_id)

    case user_id do
      nil ->
        add_error(changeset, :user_id, "can't be blank", validation: :required)

      _ ->
        changeset
    end
  end

  @doc """
  Validate longitude and latitude inside Geo.Point object
  """
  def validate_location(changeset, field) do
    validate_change(changeset, field, fn _, value ->
      {lat, lng} = value.coordinates

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
