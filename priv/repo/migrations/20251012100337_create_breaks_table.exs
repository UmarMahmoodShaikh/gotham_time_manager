defmodule Gotham.Repo.Migrations.CreateBreaksTable do
  use Ecto.Migration

  def change do
    create table(:breaks, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :break_type, :string, null: false, default: "regular"
      add :start_time, :utc_datetime, null: false
      add :end_time, :utc_datetime
      add :duration_minutes, :integer
      add :status, :string, null: false, default: "active"
      add :notes, :text

      timestamps()
    end

    create index(:breaks, [:user_id])
    create index(:breaks, [:start_time])
    create index(:breaks, [:status])
  end
end
