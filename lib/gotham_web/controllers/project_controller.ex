defmodule GothamWeb.ProjectController do
  use GothamWeb, :controller

  alias Gotham.Repo
  alias Gotham.Organizations
  alias Gotham.Organizations.Project
  alias Gotham.Accounts.Role

  action_fallback GothamWeb.FallbackController

#  def index(conn, _params) do
#    projects = Organizations.list_projects()
#    render(conn, :index, projects: projects)
#  end

  def index(conn, params) do
    # Get the status from params
    case Map.get(params, "status") do
      nil ->
        # No status filter, get all projects
        projects = Gotham.Organizations.list_projects()
        render(conn, :index, projects: projects)

      status ->
        # Make status case-insensitive
        status = String.downcase(status)

        import Ecto.Query

        # Safe Ecto query
        query =
          from p in Gotham.Organizations.Project,
               where: fragment("lower(?)", p.status) == ^status

        # Make sure to use correct Repo alias
        alias Gotham.Repo

        projects =
          query
          |> Repo.all()
          |> Repo.preload([:teams, :tasks])

        render(conn, :index, projects: projects)
    end
  end

  # Add new projects only by admins/manager role
  def create(conn, %{"project" => project_params}) do
    authorize_roles!(conn, [Role.admin_id(), Role.manager_id()])

    required_fields = ["manager_id", "team_id"]
    missing_fields = Enum.filter(required_fields, fn field -> Map.get(project_params, field) in [nil, ""] end)

    with [] <- missing_fields do
      case Organizations.create_project(project_params) do
        {:ok, project} ->
          project = Gotham.Repo.preload(project, [:teams, :tasks])
          render(conn, :show, project: project)

        {:error, %Ecto.Changeset{} = changeset} ->
          json(conn, GothamWeb.ChangesetJSON.error(%{changeset: changeset}))

        {:error, message} when is_binary(message) ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{errors: [%{status: "422", detail: message}]})
      end
    else
      missing when is_list(missing) ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: [%{status: "422", detail: "Missing required fields: #{Enum.join(missing, ", ")}"}]})
    end
  end

  def show(conn, %{"id" => id}) do
    project = Organizations.get_project!(id)
    render(conn, :show, project: project)
  end

#  def update(conn, %{"id" => id, "project" => project_params}) do
#    authorize_roles!(conn, [Role.admin_id(), Role.manager_id()])
#    project = Organizations.get_project!(id)
#
#    with {:ok, %Project{} = project} <- Organizations.update_project(project, project_params) do
#      render(conn, :show, project: project)
#    end
#  end
  def update(conn, %{"id" => id, "project" => project_params}) do
    authorize_roles!(conn, [Role.admin_id(), Role.manager_id()])

    project = Organizations.get_project!(id)

    # Validate required fields
    required_fields = ["manager_id", "team_id"]
    missing_fields = Enum.filter(required_fields, fn field -> Map.get(project_params, field) in [nil, ""] end)

    with [] <- missing_fields,
         {:ok, %Project{} = updated_project} <- Organizations.update_project(project, project_params) do
      # Preload associations before rendering
      updated_project = Gotham.Repo.preload(updated_project, [:teams, :tasks])
      render(conn, :show, project: updated_project)
    else
      missing when is_list(missing) ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: [%{status: "422", detail: "Missing required fields: #{Enum.join(missing, ", ")}"}]})

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(GothamWeb.ChangesetJSON.error(%{changeset: changeset}))
    end
  end

  def delete(conn, %{"id" => id}) do
    authorize_roles!(conn, [Role.admin_id()])
    project = Organizations.get_project!(id)

    with {:ok, %Project{}} <- Organizations.delete_project(project) do
      send_resp(conn, :no_content, "")
    end
  end

  # Add tasks in a project and assign tasks to users only by admin/manager role
  def add_task(conn, %{"id" => project_id, "task_id" => task_id}) do
    authorize_roles!(conn, [Role.admin_id(), Role.manager_id()])

    with {:ok, _pt} <- Organizations.add_task_to_project(project_id, task_id) do
      project = Organizations.get_project!(project_id)
      render(conn, :show, project: project)
    end
  end

  # Add project to team
  def add_to_team(conn, %{"id" => project_id, "team_id" => team_id}) do
    authorize_roles!(conn, [Role.admin_id(), Role.manager_id()])

    with {:ok, _tp} <- Organizations.add_project_to_team(team_id, project_id) do
      project = Organizations.get_project!(project_id)
      render(conn, :show, project: project)
    end
  end

  defp authorize_roles!(conn, allowed_role_ids) do
    case conn.assigns[:current_user] do
      %{role_id: role_id} -> if role_id in allowed_role_ids, do: :ok, else: conn |> forbid()
      _ -> conn |> forbid()
    end
  end

  defp forbid(conn) do
    conn
    |> put_status(:forbidden)
    |> json(%{errors: [%{detail: "forbidden"}]})
    |> halt()
  end
end
