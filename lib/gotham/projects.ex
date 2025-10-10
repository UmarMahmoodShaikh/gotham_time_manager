defmodule Gotham.Projects do
  alias Gotham.Repo
  alias Gotham.Organizations.Project

  def get_project(id) do
    case Repo.get(Project, id) do
      nil -> {:error, :not_found}
      project -> {:ok, project}
    end
  end
end
