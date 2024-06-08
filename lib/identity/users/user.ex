defmodule Identity.Users.User do
  use Ecto.Schema
  import Ecto.Changeset

  @mail_regex ~r/^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$/

  schema "users" do
    field :password_hash, :string
    field :email, :string
    field :oid, Ecto.UUID
    field :firstname, :string
    field :lastname, :string
    field :password, :string, virtual: true

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :oid, :firstname, :lastname, :password])
    |> validate_required([:email, :firstname, :lastname])
    |> maybe_validate_password()
    |> validate_format(:email, @mail_regex, message: "invalid email")
    |> unique_constraint(:oid)
    |> unique_constraint(:email)
    |> put_password_hash()
    |> maybe_put_oid()
    |> put_downcased_email()
  end

  defp maybe_validate_password(changeset) do
    if changeset.data.id do
      changeset
    else
      changeset
      |> validate_required([:password])
      |> validate_length(:password, min: 6)
    end
  end

  defp put_password_hash(%Ecto.Changeset{valid?: true, changes: %{password: pass}} = changeset) do
    changeset |> put_change(:password_hash, Argon2.hash_pwd_salt(pass))
  end

  defp put_password_hash(changeset), do: changeset

  defp put_downcased_email(%Ecto.Changeset{valid?: true, changes: %{email: email}} = changeset) do
    changeset |> put_change(:email, email |> String.downcase())
  end

  defp put_downcased_email(changeset), do: changeset

  defp maybe_put_oid(%Ecto.Changeset{valid?: true} = changeset) do
    if changeset.data.id do
      changeset
    else
      case get_field(changeset, :oid) do
        nil -> changeset |> put_change(:oid, Ecto.UUID.generate())
        _ -> changeset
      end
    end
  end

  defp maybe_put_oid(changeset), do: changeset
end
