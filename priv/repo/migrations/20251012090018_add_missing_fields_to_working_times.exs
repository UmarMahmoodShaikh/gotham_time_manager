defmodule Gotham.Repo.Migrations.AddMissingFieldsToWorkingTimes do
  use Ecto.Migration

  def change do
    alter table(:working_times) do
      add :work_location, :string
      add :latitude, :decimal, precision: 10, scale: 8
      add :longitude, :decimal, precision: 11, scale: 8
      add :total_hours, :decimal, precision: 5, scale: 2
      add :status, :string, default: "pending"
      add :is_manual, :boolean, default: false
      add :justification, :text
      add :notes, :text
      add :approved_by, references(:users, on_delete: :nilify_all)
      add :approved_at, :utc_datetime
      add :rejection_reason, :text
    end

    create index(:working_times, [:status])
    create index(:working_times, [:approved_by])
    create index(:working_times, [:work_location])
  end
end