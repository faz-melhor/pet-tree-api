defmodule PetreeApi.Repo.Migrations.CreateTrees do
  use Ecto.Migration

  def change do
    create table(:trees) do
      add :description, :string
      add :specie, :string
      add :fruitful, :boolean, default: false, null: false
      add :status, :string
      add :lat, :decimal
      add :lng, :decimal
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:trees, [:user_id])
  end
end
