defmodule PetreeApi.Factory do
  @moduledoc """
  Factories for test.
  """

  use ExMachina.Ecto, repo: PetreeApi.Repo

  alias PetreeApi.{Accounts.User, Trees.Tree}

  def user_factory do
    %User{
      email: sequence(:email, &"email-#{&1}@example.com"),
      name: "Jane Smith",
      nickname: "Jane",
      password_hash: Bcrypt.hash_pwd_salt("123456")
    }
  end

  def tree_factory do
    %Tree{
      description: sequence(:description, &"Jane's Lemon Tree #{&1}"),
      fruitful: false,
      lat: Decimal.new("-34.574956"),
      lng: Decimal.new("58.408454"),
      status: :pending,
      specie: "Tahiti Lemon",
      user: build(:user)
    }
  end
end
