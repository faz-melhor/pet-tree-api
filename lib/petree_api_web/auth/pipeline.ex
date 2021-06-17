defmodule PetreeApiWeb.Auth.Pipeline do
  @moduledoc """
  Authentication Pipeline
  """
  use Guardian.Plug.Pipeline,
    otp_app: :petree_api,
    module: PetreeApiWeb.Auth.Guardian,
    error_handler: PetreeApiWeb.Auth.ErrorHandler

  plug Guardian.Plug.VerifyHeader, realm: "Bearer"
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource
end
