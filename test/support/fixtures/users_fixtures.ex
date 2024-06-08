defmodule Identity.UsersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Identity.Users` context.
  """

  @doc """
  Generate a user.
  """
  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        email: "test@email.com",
        firstname: "firstname",
        lastname: "lastname",
        password: "password"
      })
      |> Identity.Users.create_user()

    user
  end
end
