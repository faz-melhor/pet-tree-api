defmodule PetreeApiWeb.Auth.Guardian do
  @moduledoc """
  Guardian module that deals with the JWT insertion
  and extraction of information
  """
  use Guardian, otp_app: :petree_api

  def subject_for_token(user, _claims) do
    sub = to_string(user.id)
    {:ok, sub}
  end

  def resource_from_claims(claims) do
    id = claims["sub"]
    resource = PetreeApi.Accounts.get_user!(id)
    {:ok, resource}
  end
end
