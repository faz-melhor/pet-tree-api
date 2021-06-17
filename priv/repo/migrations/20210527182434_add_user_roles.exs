defmodule PetreeApi.Repo.Migrations.AddUserRoles do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :roles, {:array, :string}, default: ["user"]
    end
  end
end
