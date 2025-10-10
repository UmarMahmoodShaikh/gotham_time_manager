defmodule Gotham.Organizations.TeamProject do
  use Ecto.Schema
  import Ecto.Changeset

  schema "teams_projects" do
    belongs_to :team, Gotham.Organizations.Team, type: :id
    belongs_to :project, Gotham.Organizations.Project, type: :id

    timestamps(type: :utc_datetime)
  end

  def changeset(team_project, attrs) do
    team_project
    |> cast(attrs, [:team_id, :project_id])
    |> validate_required([:team_id, :project_id])
    |> assoc_constraint(:team)
    |> assoc_constraint(:project)
    |> unique_constraint([:team_id, :project_id])
  end
end
