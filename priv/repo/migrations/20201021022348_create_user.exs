defmodule PetreeApi.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:user) do
      add :name, :string
      add :email, :string
      add :password, :string

      timestamps()
    end

    create unique_index(:user, [:email])
  end
end
