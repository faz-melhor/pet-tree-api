defmodule PetreeApi.Trees.Policy do
  @moduledoc """
  Authorization policies for Trees context.
  """
  @behaviour Bodyguard.Policy

  alias PetreeApi.Accounts.User
  alias PetreeApi.Trees.Tree

  def authorize(:create_tree, user_id, %User{id: user_id}), do: true

  def authorize(:update_tree, %User{id: user_id}, %Tree{user_id: user_id}), do: true

  def authorize(:delete_tree, %User{id: user_id}, %Tree{user_id: user_id}), do: true

  def authorize(:update_tree_status, %User{roles: roles}, _) do
    if Enum.member?(roles, "admin") do
      :ok
    else
      {:error, :forbidden}
    end
  end

  def authorize(_, _, _), do: {:error, :forbidden}
end
