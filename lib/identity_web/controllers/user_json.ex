defmodule IdentityWeb.UserJSON do
  alias Identity.Users.User

  @doc """
  Renders a single user.
  """
  def show(%{user: user}) do
    %{data: data(user)}
  end

  defp data(%User{} = user) do
    %{
      id: user.oid,
      email: user.email,
      firstname: user.firstname,
      lastname: user.lastname
    }
  end
end
