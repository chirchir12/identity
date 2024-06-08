defmodule IdentityWeb.Router do
  use IdentityWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :maybe_auth do
    plug IdentityWeb.Pipelines.MaybeAuthPipeline
  end

  pipeline :ensure_auth do
    plug IdentityWeb.Pipelines.EnsureAuthPipeline
  end

  scope("/api/auth", IdentityWeb) do
    pipe_through [:api, :maybe_auth]

    post "/login", AuthController, :login
    post "/register", AuthController, :register

    post "/token/renew", AuthController, :refresh_token
    post "/token/revoke", AuthController, :revoke_refresh_token
  end

  scope "/api", IdentityWeb do
    pipe_through [:api, :maybe_auth, :ensure_auth]

    get "/users/profile", UserController, :profile
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:identity, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      live_dashboard "/dashboard", metrics: IdentityWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
