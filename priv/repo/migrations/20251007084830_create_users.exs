defmodule Gotham.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :username, :string
      add :email, :string
      add :first_name, :string
      add :last_name, :string
      add :password_hash, :string
      add :is_visually_challenged, :boolean, default: false, null: false
      add :role_id, references(:roles, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create unique_index(:users, [:email])
    create index(:users, [:role_id])
  end
end
