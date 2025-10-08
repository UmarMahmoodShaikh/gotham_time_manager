defmodule Gotham.Repo.Migrations.CreateUnrecognizedWorks do
  use Ecto.Migration

  def change do
    create table(:unrecognized_works) do
      add :description, :text
      add :working_time_id, references(:working_times, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:unrecognized_works, [:working_time_id])
  end
end
