defmodule Gotham.Repo.Migrations.CreateTaskSkills do
  use Ecto.Migration

  def change do
    create table(:task_skills) do
      add :task_id, references(:tasks, on_delete: :nothing)
      add :skill_id, references(:skills, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:task_skills, [:task_id])
    create index(:task_skills, [:skill_id])
  end
end
