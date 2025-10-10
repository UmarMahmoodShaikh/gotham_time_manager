defmodule Gotham.Repo.Migrations.ReplaceStartAndEndDateWithDateInSchedules do
  use Ecto.Migration

  def up do
    alter table(:schedules) do
      remove :start_date
      remove :end_date
      add :date, :date, default: fragment("CURRENT_DATE"), null: false
    end
  end

  def down do
    alter table(:schedules) do
      remove :date
      add :start_date, :date
      add :end_date, :date
    end
  end
end
