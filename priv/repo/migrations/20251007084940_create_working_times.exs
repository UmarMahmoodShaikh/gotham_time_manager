defmodule Gotham.Repo.Migrations.CreateWorkingTimes do
  use Ecto.Migration

  def change do
    create table(:working_times) do
      add :start_time, :utc_datetime
      add :end_time, :utc_datetime
      add :is_manual_entry, :boolean, default: false, null: false
      add :validation_status, :string
      add :unpaid_overtime_hours, :decimal
      add :is_transition_time, :boolean, default: false, null: false
      add :user_id, references(:users, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:working_times, [:user_id])
  end
end
