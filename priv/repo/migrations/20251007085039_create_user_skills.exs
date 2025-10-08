defmodule Gotham.Repo.Migrations.CreateUserSkills do
  use Ecto.Migration

  def change do
    create table(:user_skills) do
      add :user_id, references(:users, on_delete: :nothing)
      add :skill_id, references(:skills, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:user_skills, [:user_id])
    create index(:user_skills, [:skill_id])
  end
end
