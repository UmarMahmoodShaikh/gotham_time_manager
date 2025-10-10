defmodule Gotham.Organizations.Project do
  use Ecto.Schema
  import Ecto.Changeset

  alias Gotham.Organizations.{Team, TeamProject, ProjectTask}
  alias Gotham.Activities.Task

  schema "projects" do
    field :name, :string
    field :description, :string
    field :status, :string, default: "pending"

    many_to_many :teams, Team, join_through: TeamProject
    many_to_many :tasks, Task, join_through: ProjectTask

    timestamps(type: :utc_datetime)
  end

  def changeset(project, attrs) do
    project
    |> cast(attrs, [:name, :description, :status])
    |> validate_required([:name])
    |> validate_inclusion(:status,
         [
           "in_development",
           "completed",
           "cancelled",
           "on_hold",
           "in_qa_verification",
           "pending",
           "in_production",
           "in_pre_production",
           "in_design",
           "in_analysis",
           "bug_fixing",
           "active",
           "archived",
         ]
       )
    |> unique_constraint(:name)
  end
end
