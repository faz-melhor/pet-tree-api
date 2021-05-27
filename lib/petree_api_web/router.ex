defmodule PetreeApiWeb.Router do
  use PetreeApiWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug :validate_uuid
  end

  pipeline :token_authenticated do
    plug PetreeApiWeb.Auth.Pipeline
  end

  scope "/v1", PetreeApiWeb do
    pipe_through :api

    post "/users", UserController, :create
    post "/auth", AuthController, :create
  end

  scope "/v1", PetreeApiWeb do
    pipe_through [:token_authenticated, :api]

    get "/trees", TreeController, :index

    get "/trees/:id", TreeController, :show
    patch "/trees/:id", TreeController, :update

    get "/users", UserController, :index

    get "/users/:id", UserController, :show
    patch "/users/:id", UserController, :update
    delete "/users/:id", UserController, :delete

    get "/users/:id/trees", TreeController, :index
    post "/users/:id/trees", TreeController, :create

    get "/users/:user_id/trees/:tree_id", TreeController, :show
    patch "/users/:user_id/trees/:tree_id", TreeController, :update
    delete "/users/:user_id/trees/:tree_id", TreeController, :delete
  end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through [:fetch_session, :protect_from_forgery]
      live_dashboard "/dashboard", metrics: PetreeApiWeb.Telemetry
    end
  end

  defp validate_uuid(
         %Plug.Conn{path_params: %{"user_id" => user_id, "tree_id" => tree_id}} = conn,
         _opts
       ) do
    if Ecto.UUID.cast(user_id) == :error or Ecto.UUID.cast(tree_id) == :error do
      conn |> Plug.Conn.send_resp(404, "") |> Plug.Conn.halt()
    else
      conn
    end
  end

  defp validate_uuid(%Plug.Conn{path_params: %{"id" => id}} = conn, _opts) do
    case Ecto.UUID.cast(id) do
      :error -> conn |> Plug.Conn.send_resp(404, "") |> Plug.Conn.halt()
      _ -> conn
    end
  end

  defp validate_uuid(conn, _opts) do
    conn
  end
end
