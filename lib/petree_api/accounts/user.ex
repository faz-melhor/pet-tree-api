defmodule PetreeApi.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :email, :string
    field :name, :string
    field :nickname, :string
    field :password_hash, :string

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :nickname, :email, :password_hash])
    |> validate_required([:name, :nickname, :email, :password_hash])
    |> unique_constraint(:email)
  end
end
