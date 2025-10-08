defmodule Gotham.Organizations.ProjectTask do
  use Ecto.Schema
  import Ecto.Changeset

  alias Gotham.Organizations.Project
  alias Gotham.Activities.Task

  schema "projects_tasks" do
    belongs_to :project, Project, type: :id
    belongs_to :task, Task, type: :id

    timestamps(type: :utc_datetime)
  end

  def changeset(project_task, attrs) do
    project_task
    |> cast(attrs, [:project_id, :task_id])
    |> validate_required([:project_id, :task_id])
    |> assoc_constraint(:project)
    |> assoc_constraint(:task)
    |> unique_constraint([:project_id, :task_id])
  end
end
