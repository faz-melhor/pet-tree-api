defmodule PetreeApi.Factory do
  @moduledoc """
  Factories for test.
  """

  use ExMachina.Ecto, repo: PetreeApi.Repo

  alias PetreeApi.{Accounts.User, Trees.Tree}

  def user_factory do
    %User{
      email: sequence(:email, &"email-#{&1}@example.com"),
      name: sequence(:name, &"Jane Smith-#{&1}"),
      nickname: sequence(:nickname, &"Jane-#{&1}"),
      password_hash: Bcrypt.hash_pwd_salt("123456")
    }
  end

  def tree_factory do
    lat = -34.57613278928747
    lng = -58.40964771739279

    %Tree{
      description: sequence(:description, &"Jane's Lemon Tree #{&1}"),
      fruitful: false,
      location: %Geo.Point{coordinates: {lat, lng}, srid: 4326},
      status: :pending,
      specie: "Tahiti Lemon",
      user: build(:user)
    }
  end
end
