defmodule IdentityWeb.AuthJSON do
  def auth_user(%{user: user, access_token: access_token, refresh_token: refresh_token}) do
    %{
      data: %{
        user: %{
          email: user.email,
          firstname: user.firstname,
          lastname: user.lastname
        },
        access_token: access_token,
        refresh_token: refresh_token
      }
    }
  end

  def token(%{access_token: access_token}) do
    %{
      data: %{
        access_token: access_token
      }
    }
  end
end
