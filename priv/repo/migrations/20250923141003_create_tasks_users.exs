defmodule GothamTimeManager.Repo.Migrations.CreateTasksUsers do
  use Ecto.Migration

  def change do
    create table(:tasks_users) do
      add :task_id, references(:tasks, on_delete: :delete_all), null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps()
    end

    create unique_index(:tasks_users, [:task_id, :user_id])
  end
end
