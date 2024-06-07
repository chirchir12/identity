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
end
