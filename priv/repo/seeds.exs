# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     PetreeApi.Repo.insert!(%PetreeApi.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias PetreeApi.Accounts

with {:ok, admin} <-
       Accounts.create_user(%{
         name: "Admin",
         nickname: "Admin",
         email: "admin@pettree.com",
         password: "admin"
       }) do
  {:ok, _} = Accounts.roles_update(admin, %{roles: ["user", "admin"]})
end
