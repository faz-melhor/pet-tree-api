defmodule PetreeApi.Repo.Migrations.CreateTree do
  use Ecto.Migration

  def change do
    create table(:tree) do
      add :user_id, :integer
      add :lat, :float
      add :lng, :float
      add :description, :string
      add :species_id, :integer
      add :status, :string
      add :fruitful, :boolean, default: false, null: false

      timestamps()
    end

  end
end
