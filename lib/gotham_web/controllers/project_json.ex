defmodule GothamWeb.ProjectJSON do
  alias Gotham.Organizations.Project

  def index(%{projects: projects}), do: %{data: for(p <- projects, do: data(p))}
  def show(%{project: project}), do: %{data: data(project)}

  defp data(%Project{} = project) do
    %{
      id: project.id,
      name: project.name,
      description: project.description,
      status: project.status,
      team_ids: Enum.map(project.teams || [], & &1.id),
      task_ids: Enum.map(project.tasks || [], & &1.id)
    }
  end
end
