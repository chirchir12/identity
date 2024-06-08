defmodule IdentityWeb.Pipelines.MaybeAuthPipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :identity,
    error_handler: IdentityWeb.Errors.GuardianAuthErrorHandler,
    module: Identity.Guardian

  # If there is an authorization header, restrict it to an access token and validate it
  plug Guardian.Plug.VerifyHeader, claims: %{"typ" => "access"}
  # Load the user if either of the verifications worked
  plug Guardian.Plug.LoadResource, allow_blank: true
end
