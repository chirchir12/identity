defmodule Identity.Guardian do
  use Guardian, otp_app: :identity
  alias Identity.Users
  alias Identity.Users.User

  def subject_for_token(%User{oid: id}, _claims) do
    {:ok, id}
  end

  def subject_for_token(_, _) do
    {:error, :user_id_not_provided}
  end

  def resource_from_claims(%{"sub" => id}) do
    user = Users.get_user_by!(id, :uuid)
    {:ok, user}
  rescue
    Ecto.NoResultsError -> {:error, :user_not_found}
  end

  def after_encode_and_sign(resource, claims, token, _options) do
    with {:ok, _} <- Guardian.DB.after_encode_and_sign(resource, claims["typ"], claims, token) do
      {:ok, token}
    end
  end

  def on_verify(claims, token, _options) do
    IO.inspect(claims)

    with {:ok, _} <- Guardian.DB.on_verify(claims, token) do
      {:ok, claims}
    end
  end

  def on_revoke(claims, token, _options) do
    with {:ok, _} <- Guardian.DB.on_revoke(claims, token) do
      {:ok, claims}
    end
  end
end
