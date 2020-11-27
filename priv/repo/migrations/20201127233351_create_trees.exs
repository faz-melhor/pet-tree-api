defmodule PetreeApi.Repo.Migrations.CreateTrees do
  @moduledoc """
  Creating Trees in the database
  """
  use Ecto.Migration

  def change do
    create table(:trees, primary_key: false) do
      add :id, :binary_id, primary_key: true, default: fragment("gen_random_uuid()")
      add :description, :string
      add :specie, :string
      add :fruitful, :boolean, default: false, null: false
      add :status, :string
      add :lat, :decimal
      add :lng, :decimal
      add :user_id, references(:users, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:trees, [:user_id])
  end
end
