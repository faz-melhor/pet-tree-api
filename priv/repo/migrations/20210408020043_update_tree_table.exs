defmodule PetreeApi.Repo.Migrations.UpdateTreeTable do
  @moduledoc """
  Enabling postgis and removing lat and lng field to create a geographic point field
  """
  use Ecto.Migration

  def change do
    execute("CREATE EXTENSION IF NOT EXISTS postgis")

    alter table(:trees) do
      remove :lat
      remove :lng
    end

    execute("SELECT AddGeometryColumn('trees', 'location', 4326, 'POINT', 2)")
    execute("CREATE INDEX tree_location_index on trees USING gist (location)")
  end
end
