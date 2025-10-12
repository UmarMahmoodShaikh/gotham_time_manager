defmodule Gotham.Repo.Migrations.CreateTimeEntries do
  use Ecto.Migration

  def change do
    create table(:time_entries) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :clock_in, :utc_datetime, null: false
      add :clock_out, :utc_datetime
      add :total_hours, :decimal, precision: 5, scale: 2
      add :work_location, :string, null: false
      add :notes, :text
      add :latitude, :decimal, precision: 10, scale: 8
      add :longitude, :decimal, precision: 11, scale: 8
      add :status, :string, null: false, default: "in_progress"
      add :is_manual, :boolean, default: false, null: false
      add :justification, :text
      add :approved_by, references(:users, on_delete: :nilify_all)
      add :approved_at, :utc_datetime
      add :rejected_by, references(:users, on_delete: :nilify_all)
      add :rejected_at, :utc_datetime
      add :approval_notes, :text
      add :rejection_reason, :text

      timestamps(type: :utc_datetime)
    end

    create index(:time_entries, [:user_id])
    create index(:time_entries, [:clock_in])
    create index(:time_entries, [:status])
    create index(:time_entries, [:work_location])
    create index(:time_entries, [:approved_by])
    create index(:time_entries, [:rejected_by])
  end
end
