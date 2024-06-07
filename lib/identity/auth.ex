defmodule Identity.Auth do
  alias Identity.Users
  alias Identity.Users.User
  alias Identity.Guardian

  def login(email, plain_text_password) do
    with {:ok, user} <- get_user_by_email(email),
         {:ok, true} <- verify_password(plain_text_password, user.password_hash),
         {:ok, access_token, refresh_token} <- auth_reply(user) do
      {:ok, user, access_token, refresh_token}
    end
  end

  def register(params) do
    with {:ok, user} <- Users.create_user(params),
         {:ok, access_token, refresh_token} <- auth_reply(user) do
      {:ok, user, access_token, refresh_token}
    end
  end

  def renew_access(refresh_token) do
    {:ok, _old_stuff, {new_access_token, _new_claims}} =
      Guardian.exchange(refresh_token, "refresh", "access", ttl: get_ttl_opt(:access))

    {:ok, new_access_token}
  end

  def revoke_refresh_token(refresh_token) do
    {:ok, _claim} = Guardian.revoke(refresh_token)
    :ok
  end

  defp get_user_by_email(email) do
    user = Users.get_user_by!(email, :email)
    {:ok, user}
  rescue
    Ecto.NoResultsError -> {:error, :invalid_email}
  end

  defp verify_password(plain_password, hash_password) do
    case Argon2.verify_pass(plain_password, hash_password) do
      true -> {:ok, true}
      false -> {:error, :invalid_password}
    end
  end

  defp create_access_token(%User{} = user) do
    {:ok, access_token, _claim} =
      Guardian.encode_and_sign(user, %{grant_type: "password"}, token_type: :access, ttl: get_ttl_opt(:access))

    {:ok, access_token}
  end

  defp create_refresh_token(%User{} = user) do
    {:ok, refresh_token, _claim} =
      Guardian.encode_and_sign(user, %{}, token_type: :refresh, ttl: get_ttl_opt(:refresh))

    {:ok, refresh_token}
  end

  defp auth_reply(%User{} = user) do
    with {:ok, access_token} <- create_access_token(user),
         {:ok, refresh_token} <- create_refresh_token(user) do
      {:ok, access_token, refresh_token}
    end
  end

  defp get_ttl_opt(:access) do
      :identity
      |> Application.get_env(Identity.Guardian)
      |> Keyword.get(:tokens)
      |> Keyword.get(:access)
      |> Keyword.get(:ttl)
  end

  defp get_ttl_opt(:refresh) do
    :identity
      |> Application.get_env(Identity.Guardian)
      |> Keyword.get(:tokens)
      |> Keyword.get(:refresh)
      |> Keyword.get(:ttl)
  end
end
