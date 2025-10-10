defmodule Gotham.Repo.Migrations.AddStartAndEndTimeToShifts do
  use Ecto.Migration

  def change do
    alter table(:shifts) do
      add :start_time, :time
      add :end_time, :time
    end
  end
end
