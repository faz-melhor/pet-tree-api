defmodule PetreeApiWeb.Router do
  use PetreeApiWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", PetreeApiWeb do
    pipe_through :api
    get "/trees", TreeController, :index
    post "/trees", TreeController, :create
    get "/trees/:id", TreeController, :show
    delete "/trees/:id", TreeController, :delete
    put "/trees/:id", TreeController, :update

    resources "/users", UserController
    # get "/users", UserController, :index
    # post "/users", UserController, :create
    # get "/users/:id", UserController, :show
    # delete "/users/:id", UserController, :delete
    # put "/users/:id", UserController, :update
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
end
