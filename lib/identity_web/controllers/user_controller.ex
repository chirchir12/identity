defmodule IdentityWeb.UserController do
  use IdentityWeb, :controller

  alias Identity.Users
  alias Identity.Users.User
  import Identity.GuardianHelpers

  plug IdentityWeb.CheckRolesPlug, ["individual.customer"]
  plug IdentityWeb.CheckGrantTypePlug, ["password"]

  action_fallback IdentityWeb.FallbackController

  def update(conn, %{"user" => user_params}) do
    with {:ok, user} <- get_current_user(conn),
         attrs <- Map.put(user_params, "oid", user.oid),
         {:ok, %User{} = user} <- Users.update_user(user, attrs) do
      conn
      |> put_status(:ok)
      |> render(:show, user: user)
    end
  end

  def profile(conn, _params) do
    {:ok, user} = conn |> get_current_user()
    render(conn, :show, user: user)
  end
end
