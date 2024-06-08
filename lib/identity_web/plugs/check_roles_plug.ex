defmodule IdentityWeb.CheckRolesPlug do
  import Phoenix.Controller
  import Plug.Conn
  import Identity.GuardianHelpers

  def init(default), do: default

  def call(conn, roles) do
    with {:ok, claim} <- get_current_claim(conn) do
      role = claim["role"]

      if(role in roles) do
        conn
      else
        conn
        |> put_status(:forbidden)
        |> put_view(json: IdentityWeb.ErrorJSON)
        |> render(:"403",
          error: %{
            status: :forbidden,
            reason: "Resource forbidden, not enough roles"
          }
        )
        |> halt()
      end
    end
  end
end
