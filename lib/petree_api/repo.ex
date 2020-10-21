defmodule PetreeApi.Repo do
  use Ecto.Repo,
    otp_app: :petree_api,
    adapter: Ecto.Adapters.Postgres
end
