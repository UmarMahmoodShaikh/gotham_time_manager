defmodule Gotham.Repo.Migrations.CreateSessionsTable do
  use Ecto.Migration

  def change do
    create table(:sessions) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :token, :string, null: false
      add :csrf_token, :string
      add :expires_at, :utc_datetime, null: false
      add :refresh_token, :string

      timestamps(type: :utc_datetime)
    end

    create unique_index(:sessions, [:token])
    create index(:sessions, [:user_id])
    create index(:sessions, [:expires_at])
  end
end