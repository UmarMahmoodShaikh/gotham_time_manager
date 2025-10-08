defmodule Gotham.Repo.Migrations.CreateProjectsTasks do
  use Ecto.Migration

  def change do
    create table(:projects_tasks) do
      add :project_id, references(:projects, on_delete: :delete_all), null: false
      add :task_id, references(:tasks, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:projects_tasks, [:project_id, :task_id])
    create index(:projects_tasks, [:project_id])
    create index(:projects_tasks, [:task_id])
  end
end
