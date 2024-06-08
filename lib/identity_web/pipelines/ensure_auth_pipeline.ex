defmodule IdentityWeb.Pipelines.EnsureAuthPipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :identity,
    error_handler: IdentityWeb.Errors.GuardianAuthErrorHandler,
    module: Identity.Guardian

  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource
end
