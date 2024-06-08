defmodule IdentityWeb.CheckGrantTypePlug do
  import Phoenix.Controller
  import Plug.Conn
  import Identity.GuardianHelpers

  def init(default), do: default

  def call(conn, grants) do
    with {:ok, claim} <- get_current_claim(conn) do
      grant = claim["grant_type"]

      if(grant in grants) do
        conn
      else
        conn
        |> put_status(:forbidden)
        |> put_view(json: IdentityWeb.ErrorJSON)
        |> render(:"403",
          error: %{
            status: :forbidden,
            reason: "resource forbidden due to grant policy"
          }
        )
        |> halt()
      end
    end
  end
end
