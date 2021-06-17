defmodule PetreeApi.Accounts.User do
  @moduledoc """
  User schema
  """
  use PetreeApi.Schema
  use Filterable.Phoenix.Model

  import Ecto.Changeset
  import Ecto.Query, warn: false

  alias PetreeApi.Trees.Tree

  filterable do
    limitable()
  end

  schema "users" do
    field :email, :string
    field :name, :string
    field :nickname, :string
    field :password, :string, virtual: true
    field :password_hash, :string
    field :roles, {:array, :string}, default: ["user"]
    has_many :trees, Tree

    timestamps()
  end

  @doc false
  def create_changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :nickname, :email, :password])
    |> validate_required([:name, :nickname, :email, :password])
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:email)
    |> put_password_hash()
  end

  def update_changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :nickname, :email, :password])
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:email)
    |> put_password_hash()
  end

  def roles_update_changeset(user, attrs) do
    user
    |> cast(attrs, [:roles])
    |> validate_required([:roles])
    |> validate_roles()
  end

  defp validate_roles(changeset) do
    roles = get_field(changeset, :roles)
    req_roles = ["user", "admin"]

    if Enum.all?(roles, fn role -> role in req_roles end) and !Enum.empty?(roles) and
         "user" in roles do
      changeset
    else
      add_error(changeset, :roles, "is invalid")
    end
  end

  defp put_password_hash(
         %Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset
       ) do
    put_change(changeset, :password_hash, Bcrypt.hash_pwd_salt(password))
  end

  defp put_password_hash(changeset), do: changeset
end
