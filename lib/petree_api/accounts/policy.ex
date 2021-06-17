defmodule PetreeApi.Accounts.Policy do
  @moduledoc """
  Authorization policies for Accounts context.
  """
  @behaviour Bodyguard.Policy

  alias PetreeApi.Accounts.User

  def authorize(:get_all_users, %User{roles: roles}, _) do
    if Enum.member?(roles, "admin") do
      :ok
    else
      {:error, :forbidden}
    end
  end

  def authorize(:get_user, user_id, %User{roles: roles, id: current_user_id}) do
    if Enum.member?(roles, "admin") or current_user_id == user_id do
      :ok
    else
      {:error, :forbidden}
    end
  end

  def authorize(:update_user, user_id, %User{id: user_id}), do: true

  def authorize(:delete_user, user_id, %User{id: user_id}), do: true

  def authorize(:update_user_roles, %User{roles: roles}, _) do
    if Enum.member?(roles, "admin") do
      :ok
    else
      {:error, :forbidden}
    end
  end

  def authorize(_, _, _), do: {:error, :forbidden}
end
