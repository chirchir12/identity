defmodule IdentityWeb.AuthControllerTest do
  use IdentityWeb.ConnCase
  import Identity.UsersFixtures
  alias Identity.Users.User
  alias Identity.Guardian
  alias Identity.Auth

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

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "register" do
    test "register/2 creates new account", %{conn: conn} do
      conn = post(conn, ~p"/api/auth/register", user: @create_user)

      assert %{"user" => user, "access_token" => access_token, "refresh_token" => refresh_token} =
               json_response(conn, 201)["data"]

      assert {:ok, claim} = Guardian.decode_and_verify(access_token)
      assert claim["typ"] == "access"
      assert user["email"] == "test@mail.com"

      assert {:ok, claim} = Guardian.decode_and_verify(refresh_token)
      assert claim["typ"] == "refresh"
    end

    test "register/2 throws error when invalid inputs is provided", %{conn: conn} do
      conn = post(conn, ~p"/api/auth/register", user: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "login/2" do
    setup [:create_user]

    test "return user, access and refresh token when credentials are correct", %{
      conn: conn,
      user: %User{email: email, password: password}
    } do
      conn = post(conn, ~p"/api/auth/login", email: email, password: password)

      assert %{"user" => _user, "access_token" => access_token, "refresh_token" => refresh_token} =
               json_response(conn, 200)["data"]

      assert {:ok, claim} = Guardian.decode_and_verify(access_token)
      assert claim["typ"] == "access"
      assert {:ok, claim} = Guardian.decode_and_verify(refresh_token)
      assert claim["typ"] == "refresh"
    end
  end

  describe "refresh_token" do
    setup [:create_user, :login]

    test "should return new access token", %{conn: conn, refresh: refresh} do
      conn = post(conn, ~p"/api/auth/token/renew", refresh_token: refresh)

      assert %{
               "access_token" => access_token
             } = json_response(conn, 200)["data"]

      assert {:ok, claim} = Guardian.decode_and_verify(access_token)
      assert claim["typ"] == "access"
    end
  end

  describe "revoke_refresh_token" do
    setup [:create_user, :login]

    test "should revoke valid refresh token", %{conn: conn, refresh: refresh} do
      conn = post(conn, ~p"/api/auth/token/revoke", refresh_token: refresh)
      assert response(conn, 204)

    end

  end

  defp create_user(_) do
    user = user_fixture()
    %{user: user}
  end

  defp login(%{user: %User{email: email, password: pass}}) do
    {:ok, _user, access, refresh} = Auth.login(email, pass)

    %{
      access: access,
      refresh: refresh
    }
  end
end
