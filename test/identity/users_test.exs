defmodule Identity.UsersTest do
  use Identity.DataCase

  alias Identity.Users
  alias Identity.Users.User

  describe "users" do
    alias Identity.Users.User

    import Identity.UsersFixtures

    @invalid_attrs %{password: nil, email: nil, oid: nil, firstname: nil, lastname: nil}

    test "list_users/0 returns all users" do
      user = user_fixture() |> nullify_password()
      assert Users.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture() |> nullify_password()
      assert Users.get_user!(user.id) == user
    end

    test "get_user_by!/2 returns the user with when email is passed" do
      user = user_fixture() |> nullify_password()
      assert Users.get_user_by!(user.email, :email) == user
    end

    test "get_user_by!/2 returns the user with when uuid is passed" do
      user = user_fixture() |> nullify_password()
      assert Users.get_user_by!(user.oid, :uuid) == user
    end

    test "create_user/1 with valid data creates a user" do
      valid_attrs = %{
        password: "password",
        email: "test@email.com",
        firstname: "firstname",
        lastname: "lastname"
      }

      assert {:ok, %User{} = user} = Users.create_user(valid_attrs)
      assert Argon2.verify_pass("password", user.password_hash) == true
      assert user.email == "test@email.com"
      assert user.oid != nil
      assert user.firstname == "firstname"
      assert user.lastname == "lastname"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Users.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      current_user = user_fixture() |> nullify_password()

      update_attrs = %{
        firstname: "new_firstname",
        lastname: "new_lastname"
      }

      assert {:ok, %User{} = user} = Users.update_user(current_user, update_attrs)
      assert user.password_hash == current_user.password_hash
      assert user.email == current_user.email
      assert user.oid == current_user.oid
      assert user.firstname == "new_firstname"
      assert user.lastname == "new_lastname"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture() |> nullify_password()
      assert {:error, %Ecto.Changeset{}} = Users.update_user(user, @invalid_attrs)
      assert user == Users.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Users.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Users.get_user!(user.id) end
    end
  end

  defp nullify_password(%User{} = user) do
    user = %{user | password: nil}
    user
  end
end
