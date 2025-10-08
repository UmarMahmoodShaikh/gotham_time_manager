defmodule GothamWeb.ProjectController do
  use GothamWeb, :controller

  alias Gotham.Organizations
  alias Gotham.Organizations.Project
  alias Gotham.Accounts.Role

  action_fallback GothamWeb.FallbackController

  def index(conn, _params) do
    projects = Organizations.list_projects()
    render(conn, :index, projects: projects)
  end

  # Add new projects only by admins/manager role
  def create(conn, %{"project" => project_params}) do
    authorize_roles!(conn, [Role.admin_id(), Role.manager_id()])

    with {:ok, %Project{} = project} <- Organizations.create_project(project_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/projects/#{project}")
      |> render(:show, project: project)
    end
  end

  def show(conn, %{"id" => id}) do
    project = Organizations.get_project!(id)
    render(conn, :show, project: project)
  end

  def update(conn, %{"id" => id, "project" => project_params}) do
    authorize_roles!(conn, [Role.admin_id(), Role.manager_id()])
    project = Organizations.get_project!(id)

    with {:ok, %Project{} = project} <- Organizations.update_project(project, project_params) do
      render(conn, :show, project: project)
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
