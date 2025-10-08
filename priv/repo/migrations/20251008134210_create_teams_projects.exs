defmodule Gotham.Repo.Migrations.CreateTeamsProjects do
  use Ecto.Migration

  def change do
    create table(:teams_projects) do
      add :team_id, references(:teams, on_delete: :delete_all), null: false
      add :project_id, references(:projects, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:teams_projects, [:team_id, :project_id])
    create index(:teams_projects, [:team_id])
    create index(:teams_projects, [:project_id])
  end
end
