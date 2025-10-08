defmodule Gotham.Repo.Migrations.CreateSchedules do
  use Ecto.Migration

  def change do
    create table(:schedules) do
      add :start_date, :date
      add :end_date, :date
      add :consecutive_night_count, :integer
      add :user_id, references(:users, on_delete: :nothing)
      add :shift_id, references(:shifts, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:schedules, [:user_id])
    create index(:schedules, [:shift_id])
  end
end
