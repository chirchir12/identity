defmodule Identity.AuthTest do
  use Identity.DataCase
  alias Identity.Auth
  alias Identity.Users.User
  alias Identity.Guardian
  import Identity.UsersFixtures

  @create_user %{
    "email" => "test@mail.com",
    "password" => "password",
    "firstname" => "firstname",
    "lastname" => "lastname"
  }

  @invalid_attrs %{
    email: nil,
    password: nil,
    firstname: nil,
    lastname: nil
  }

  describe "auth" do
    test "register/1 create new user" do
      assert {:ok, %User{} = user, access_token, refresh_token} = Auth.register(@create_user)
      assert user.email == "test@mail.com"
      assert Argon2.verify_pass("password", user.password_hash) == true
      assert user.oid != nil

      assert {:ok, claim} = Guardian.decode_and_verify(access_token)
      assert claim["typ"] == "access"

      assert {:ok, claim} = Guardian.decode_and_verify(refresh_token)
      assert claim["typ"] == "refresh"
    end

    test "register/1 throw changeset error when invalid attrs are passed" do
      assert {:error, %Ecto.Changeset{errors: errors}} = Auth.register(@invalid_attrs)
      assert length(errors) > 0
    end

    test "login/2 logs user in when credentials are correct" do
      user = user_fixture()

      assert {:ok, %User{} = _user, access_token, refresh_token} =
               Auth.login(user.email, user.password)

      assert {:ok, claim} = Guardian.decode_and_verify(access_token)
      assert claim["typ"] == "access"

      assert {:ok, claim} = Guardian.decode_and_verify(refresh_token)
      assert claim["typ"] == "refresh"
    end

    test "login/2 throw error invalid password if password is invalid" do
      user = user_fixture()
      assert {:error, :invalid_password} = Auth.login(user.email, "invalidPassword")
    end

    test "login/2 throw error invalid email if email user is not yet registered" do
      user = user_fixture()
      assert {:error, :invalid_email} = Auth.login("invalid@gmail.com", user.password)
    end

    test "login/2 throw error invalid email if email is invalid" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Auth.login("email", user.password)
    end

    test "renew_access/1 renews access token from valid refresh token" do
      user = user_fixture()

      assert {:ok, %User{} = _user, access_token, refresh_token} =
               Auth.login(user.email, user.password)

      assert {:ok, new_access_token} = Auth.renew_access(refresh_token)
      assert access_token !== new_access_token
      assert {:ok, claim} = Guardian.decode_and_verify(new_access_token)
      assert claim["typ"] == "access"
    end

    test "renew_access/1 will not renew if token is not valid" do
      assert {:error, :invalid_token} = Auth.renew_access("refreshtoken")
    end

    test "renew_access/1 will not renew revoked token" do
      user = user_fixture()

      assert {:ok, %User{} = _user, _access, refresh_token} =
               Auth.login(user.email, user.password)

      _ = Auth.revoke_refresh_token(refresh_token)
      assert {:error, :token_not_found} = Auth.renew_access(refresh_token)
    end

    test "revoke_refresh_token/1 will revoke existing/valid refresh token" do
      user = user_fixture()

      assert {:ok, %User{} = _user, _access_token, refresh_token} =
               Auth.login(user.email, user.password)

      :ok = Auth.revoke_refresh_token(refresh_token)
      assert {:error, :token_not_found} = Auth.renew_access(refresh_token)
    end
  end
end
