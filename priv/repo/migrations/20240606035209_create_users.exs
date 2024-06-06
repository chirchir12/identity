defmodule Identity.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email, :string, null: false
      add :oid, :uuid, null: false
      add :firstname, :string, null: false
      add :lastname, :string, null: false
      add :password_hash, :string, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:users, [:oid])
    create unique_index(:users, [:email])
  end
end
