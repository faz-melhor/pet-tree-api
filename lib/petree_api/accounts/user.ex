defmodule PetreeApi.Accounts.User do
  @moduledoc """
  User schema
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias PetreeApi.Trees.Tree

  schema "users" do
    field :email, :string
    field :name, :string
    field :nickname, :string
    field :password, :string, virtual: true
    field :password_hash, :string
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

  defp put_password_hash(
         %Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset
       ) do
    put_change(changeset, :password_hash, Bcrypt.hash_pwd_salt(password))
  end

  defp put_password_hash(changeset), do: changeset
end
