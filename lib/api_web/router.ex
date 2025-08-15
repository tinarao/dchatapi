defmodule ApiWeb.Router do
  use ApiWeb, :router
  alias ApiWeb.Plugs

  pipeline :api do
    plug CORSPlug,
      origin: ["http://localhost:1420"],
      credentials: true

    plug :accepts, ["json"]
    plug Plugs.DeviceID
  end

  pipeline :protected do
    plug Plugs.Protected
  end

  scope "/api", ApiWeb do
    pipe_through :api

    options "/*path", OptionsController, :options

    get "/auth/verify", AuthController, :verify_session
    post "/auth/login", AuthController, :login
    post "/auth/signup", AuthController, :signup
    delete "/auth/logout", AuthController, :logout

    pipe_through :protected

    get "/rooms/show/:id", RoomsController, :show
    get "/rooms/my", RoomsController, :get_my_rooms
    post "/rooms", RoomsController, :create

    post "/room_members", RoomMembersController, :create

    get "/users/:name", UsersController, :show
    get "/users/find/:query", UsersController, :find_user
  end

  # Enable LiveDashboard in development
  if Application.compile_env(:api, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      live_dashboard "/dashboard", metrics: ApiWeb.Telemetry
    end
  end
end
