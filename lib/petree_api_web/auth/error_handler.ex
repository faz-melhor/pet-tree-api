defmodule PetreeApiWeb.Auth.ErrorHandler do
  @moduledoc """
  Handle Authentication errors
  """

  import Plug.Conn

  def auth_error(conn, {type, _reason}, _opts) do
    body = Jason.encode!(%{errors: %{detail: to_string(type)}})
    send_resp(conn, 401, body)
  end
end
