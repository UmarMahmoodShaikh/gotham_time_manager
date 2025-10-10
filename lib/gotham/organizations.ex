defmodule Gotham.Organizations do
  use Phoenix.VerifiedRoutes, router: GothamWeb.Router, endpoint: GothamWeb.Endpoint
  import Ecto.Query, warn: false
  alias Gotham.Repo

  alias Gotham.Organizations.{Team, Project, TeamProject, ProjectTask}

  # Teams
  def list_teams, do: Repo.all(Team) |> Repo.preload([:manager, :projects])
  def get_team!(id), do: Repo.get!(Team, id) |> Repo.preload([:manager, :projects])

  def create_team(attrs) do
    %Team{}
    |> Team.changeset(attrs)
    |> Repo.insert()
  end

  def update_team(%Team{} = team, attrs) do
    team
    |> Team.changeset(attrs)
    |> Repo.update()
  end

  def delete_team(%Team{} = team), do: Repo.delete(team)

  def set_team_manager(%Team{} = team, manager_id) do
    update_team(team, %{manager_id: manager_id})
  end

  def set_team_status(%Team{} = team, status) when status in ["active", "dismissed"] do
    Repo.transaction(fn ->
      {:ok, team} = update_team(team, %{status: status})

      if status == "dismissed" do
        from(pt in Gotham.Organizations.ProjectTask,
          join: tp in Gotham.Organizations.TeamProject,
          on: tp.project_id == pt.project_id,
          where: tp.team_id == ^team.id
        )
        |> Repo.all()
        |> Enum.map(& &1.task_id)
        |> Enum.uniq()
        |> case do
          [] ->
            :ok

          task_ids ->
            from(t in Gotham.Activities.Task,
              where: t.id in ^task_ids and t.status != "done",
              update: [set: [status: "dismissed"]]
            )
            |> Repo.update_all([])
        end
      end

      team
    end)
  end

  # Projects
  def list_projects, do: Repo.all(Project) |> Repo.preload([:teams, :tasks])
  def get_project!(id), do: Repo.get!(Project, id) |> Repo.preload([:teams, :tasks])

  def get_team_id_by_manager(manager_id) do
    query =
      from(t in Team,
        where: t.manager_id == ^manager_id,
        select: t.id
      )

    case Repo.one(query) do
      nil -> {:error, :not_found}
      team_id -> {:ok, team_id}
    end
  end

  def create_project(attrs) do
    {manager_id, project_attrs} =
      Map.pop(attrs, "manager_id") || Map.pop(attrs, :manager_id)

    Repo.transaction(fn ->
      case %Project{} |> Project.changeset(project_attrs) |> Repo.insert() do
        {:ok, project} ->
          if manager_id do
            # Unwrap the result here
            case Gotham.Organizations.get_team_id_by_manager(manager_id) do
              {:ok, team_id} ->
                %TeamProject{}
                |> TeamProject.changeset(%{team_id: team_id, project_id: project.id})
                |> Repo.insert!()

              {:error, :not_found} ->
                Repo.rollback("Manager does not have a team")
            end
          end

          project

        {:error, changeset} ->
          Repo.rollback(changeset)
      end
    end)
  end

  def update_project(%Project{} = project, attrs) do
    project
    |> Project.changeset(attrs)
    |> Repo.update()
  end

  def delete_project(%Project{} = project), do: Repo.delete(project)

  # Associations
  def add_project_to_team(team_id, project_id) do
    %TeamProject{}
    |> TeamProject.changeset(%{team_id: team_id, project_id: project_id})
    |> Repo.insert!()
  end

  def remove_project_from_team(team_id, project_id) do
    case Repo.get_by(TeamProject, team_id: team_id, project_id: project_id) do
      nil -> {:error, :not_found}
      tp -> Repo.delete(tp)
    end
  end

  def add_task_to_project(project_id, task_id) do
    %ProjectTask{}
    |> ProjectTask.changeset(%{project_id: project_id, task_id: task_id})
    |> Repo.insert(on_conflict: :nothing)
  end

  def remove_task_from_project(project_id, task_id) do
    case Repo.get_by(ProjectTask, project_id: project_id, task_id: task_id) do
      nil -> {:error, :not_found}
      pt -> Repo.delete(pt)
    end
  end
end
