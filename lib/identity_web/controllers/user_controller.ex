defmodule IdentityWeb.UserController do
  use IdentityWeb, :controller

  alias Identity.Users
  alias Identity.Users.User
  import Identity.GuardianHelpers

  action_fallback IdentityWeb.FallbackController

  def update(conn, %{"user" => user_params}) do
    with {:ok, user} <- get_current_user(conn),
         {:ok, %User{} = user} <- Users.update_user(user, user_params) do
      render(conn, :show, user: user)
    end
  end

  def delete(conn, _params) do
    with {:ok, user} <- get_current_user(conn),
         {:ok, %User{}} <- Users.delete_user(user) do
      send_resp(conn, :no_content, "")
    end
  end

  def profile(conn, _params) do
    {:ok, user} = conn |> get_current_user()
    render(conn, :show, user: user)
  end
end
