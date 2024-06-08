defmodule IdentityWeb.UserControllerTest do
  use IdentityWeb.ConnCase

  import Identity.UsersFixtures

  alias Identity.Auth

  alias Identity.Users.User

  @update_attrs %{
    firstname: "updated",
    lastname: "updated"
  }
  @invalid_attrs %{password: nil, email: nil, firstname: nil, lastname: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "update user" do
    setup [:create_user, :login]

    test "renders user when data is valid", %{conn: conn, user: %User{oid: oid, email: email}} do
      conn = put(conn, ~p"/api/users/update", user: @update_attrs)
      assert %{"id" => ^oid} = json_response(conn, 200)["data"]
      conn = get(conn, ~p"/api/users/profile")

      assert %{
               "id" => ^oid,
               "email" => ^email,
               "firstname" => "updated",
               "lastname" => "updated"
             } = json_response(conn, 200)["data"]
    end

    test "renders ensure user does not change oid", %{conn: conn, user: %User{oid: oid, email: email}} do
      new_oid = Ecto.UUID.generate()
      attrs = Map.put(@update_attrs, "oid", new_oid)
      conn = put(conn, ~p"/api/users/update", user: attrs)
      assert %{"id" => ^oid} = json_response(conn, 200)["data"]
      conn = get(conn, ~p"/api/users/profile")

      assert %{
               "id" => ^oid,
               "email" => ^email,
               "firstname" => "updated",
               "lastname" => "updated"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = put(conn, ~p"/api/users/update", user: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "get profile" do
    setup [:create_user, :login]
    test "renders user if they are loggedin", %{conn: conn, user: %User{oid: oid, email: email}} do
      conn = get(conn, ~p"/api/users/profile")
      assert %{
        "id" => ^oid,
        "email" => ^email,
        "firstname" => "firstname",
        "lastname" => "lastname"
      } = json_response(conn, 200)["data"]

    end

  end

  defp create_user(_) do
    user = user_fixture()
    %{user: user}
  end

  defp login(%{user: user, conn: conn}) do
    {:ok, _user, access_token, _refresh} = Auth.login(user.email, user.password)
    conn = put_req_header(conn, "authorization", "Bearer #{access_token}")
    %{conn: conn}
  end
end
