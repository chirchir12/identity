defmodule IdentityWeb.UserJSON do
  alias Identity.Users.User

  @doc """
  Renders a list of users.
  """
  def index(%{users: users}) do
    %{data: for(user <- users, do: data(user))}
  end

  @doc """
  Renders a single user.
  """
  def show(%{user: user}) do
    %{data: data(user)}
  end

  defp data(%User{} = user) do
    %{
      id: user.id,
      email: user.email,
      oid: user.oid,
      firstname: user.firstname,
      lastname: user.lastname,
      password_hash: user.password_hash
    }
  end
end
