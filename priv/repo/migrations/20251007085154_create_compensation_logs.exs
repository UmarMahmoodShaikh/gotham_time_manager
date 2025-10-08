defmodule Gotham.Repo.Migrations.CreateCompensationLogs do
  use Ecto.Migration

  def change do
    create table(:compensation_logs) do
      add :pay_rate_type, :string
      add :hours_calculated, :decimal
      add :working_time_id, references(:working_times, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:compensation_logs, [:working_time_id])
  end
end
