defmodule Identity.UsersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Identity.Users` context.
  """

  @doc """
  Generate a unique user email.
  """
  def unique_user_email, do: "some email#{System.unique_integer([:positive])}"

  @doc """
  Generate a unique user oid.
  """
  def unique_user_oid, do: "some oid#{System.unique_integer([:positive])}"

  @doc """
  Generate a user.
  """
  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        email: unique_user_email(),
        firstname: "some firstname",
        lastname: "some lastname",
        oid: unique_user_oid(),
        password_hash: "some password_hash"
      })
      |> Identity.Users.create_user()

    user
  end
end
