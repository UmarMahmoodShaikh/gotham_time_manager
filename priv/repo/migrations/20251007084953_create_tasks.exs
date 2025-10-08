defmodule Gotham.Repo.Migrations.CreateTasks do
  use Ecto.Migration

  def change do
    create table(:tasks) do
      add :title, :string
      add :description, :text
      add :status, :boolean, default: false, null: false
      add :is_billable, :boolean, default: false, null: false
      add :assigned_user_id, references(:users, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:tasks, [:assigned_user_id])
  end
end
