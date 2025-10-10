defmodule GothamWeb.TaskAssignmentController do
  use GothamWeb, :controller

  alias Gotham.Accounts.Role
  alias Gotham.Activities
  alias Gotham.Projects
  alias Gotham.Repo
  alias Gotham.Activities.TaskAssignment

  action_fallback GothamWeb.FallbackController

  # Router exposes paramized endpoints:
  #   post "/tasks/:task_id/user/:user_id", TaskAssignmentController, :create
  #   delete "/tasks/:task_id/user/:user_id", TaskAssignmentController, :delete
  # Return 501 for now.

#  def create(conn, %{"task_id" => task_id, "user_id" => user_id}) do
#    alias Gotham.Accounts.Role
#    current_user = conn.assigns[:current_user]
#
#    # Check if current user is admin or manager
#    if current_user && current_user.role_id in [Role.admin_id(), Role.manager_id()] do
#      # Verify that both task and user exist
#      with {:ok, _task} <- verify_task_exists(task_id),
#           {:ok, _user} <- verify_user_exists(user_id),
#           {:ok, task_assignment} <-
#             Activities.create_task_assignment(%{task_id: task_id, user_id: user_id}) do
#        conn
#        |> put_status(:created)
#        |> put_resp_header("location", ~p"/api/task_assignments/#{task_assignment}")
#        |> render(:show, task_assignment: task_assignment)
#      else
#        {:error, :not_found} ->
#          conn
#          |> put_status(:not_found)
#          |> json(%{errors: [%{status: "404", title: "Task or User not found"}]})
#
#        {:error, changeset} ->
#          conn
#          |> put_status(:unprocessable_entity)
#          |> json(%{
#            errors: [%{status: "422", title: "Validation failed", detail: changeset.errors}]
#          })
#      end
#    else
#      conn
#      |> put_status(:forbidden)
#      |> json(%{
#        errors: [
#          %{
#            status: "403",
#            title: "Forbidden",
#            detail: "Only admins and managers can assign tasks"
#          }
#        ]
#      })
#    end
#  end
  # POST /tasks/:taskid/user/:userid
  def create(conn, params) do
    current_user = conn.assigns[:current_user]

    if current_user && current_user.role_id in [Role.admin_id(), Role.manager_id()] do
      with {:ok, task_id} <- fetch_and_cast_id(params, "taskid"),
           {:ok, user_id} <- fetch_and_cast_id(params, "userid"),
           {:ok, project_id} <- fetch_and_cast_id(params, "project_id"),
           {:ok, _task} <- Activities.get_task(task_id),
           {:ok, _user} <- Gotham.Accounts.get_user(user_id),
           {:ok, _project} <- Projects.get_project(project_id),
           {:ok, task_assignment} <- Activities.create_task_assignment(%{task_id: task_id, user_id: user_id}),
           {:ok, _project_task} <- Activities.create_project_task(%{project_id: project_id, task_id: task_id}) do
        conn
        |> put_status(:created)
        |> put_resp_header("location", ~p"/api/task_assignments/#{task_assignment}")
        |> render(:show, task_assignment: task_assignment)
      else
        {:error, :missing_param, param} ->
          conn
          |> put_status(:bad_request)
          |> json(%{errors: [%{status: "400", title: "Missing parameter", detail: "Required param #{param} is missing"}]})

        {:error, :invalid_param, param} ->
          conn
          |> put_status(:bad_request)
          |> json(%{errors: [%{status: "400", title: "Invalid parameter", detail: "#{param} must be an integer"}]})

        {:error, :not_found} ->
          conn
          |> put_status(:not_found)
          |> json(%{errors: [%{status: "404", title: "Task, User, or Project not found"}]})

        {:error, changeset} ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{errors: [%{status: "422", title: "Validation failed", detail: changeset.errors}]})
      end
    else
      conn
      |> put_status(:forbidden)
      |> json(%{errors: [%{status: "403", title: "Forbidden", detail: "Only admins and managers can assign tasks"}]})
    end
  end

  # Helper: fetch param and cast to integer
  defp fetch_and_cast_id(params, key) do
    case Map.get(params, key) do
      nil -> {:error, :missing_param, key}
      value ->
        case Integer.parse(to_string(value)) do
          {int, ""} -> {:ok, int}
          _ -> {:error, :invalid_param, key}
        end
    end
  end

  def create(conn, %{"task_assignment" => task_assignment_params}) do
    with {:ok, %TaskAssignment{} = task_assignment} <-
           Activities.create_task_assignment(task_assignment_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/task_assignments/#{task_assignment}")
      |> render(:show, task_assignment: task_assignment)
    end
  end

  def delete(conn, %{"task_id" => task_id, "user_id" => user_id}) do
    alias Gotham.Accounts.Role
    current_user = conn.assigns[:current_user]

    # Check if current user is admin or manager
    if current_user && current_user.role_id in [Role.admin_id(), Role.manager_id()] do
      # Find the task assignment by task_id and user_id
      case Activities.get_task_assignment_by_task_and_user(task_id, user_id) do
        nil ->
          conn
          |> put_status(:not_found)
          |> json(%{errors: [%{status: "404", title: "Task assignment not found"}]})

        task_assignment ->
          with {:ok, %TaskAssignment{}} <- Activities.delete_task_assignment(task_assignment) do
            send_resp(conn, :no_content, "")
          end
      end
    else
      conn
      |> put_status(:forbidden)
      |> json(%{
        errors: [
          %{
            status: "403",
            title: "Forbidden",
            detail: "Only admins and managers can unassign tasks"
          }
        ]
      })
    end
  end

  def delete(conn, %{"id" => id}) do
    task_assignment = Activities.get_task_assignment!(id)

    with {:ok, %TaskAssignment{}} <- Activities.delete_task_assignment(task_assignment) do
      send_resp(conn, :no_content, "")
    end
  end

  # Standard REST for /task_assignments
  def index(conn, _params) do
    task_assignments = Activities.list_task_assignments()
    render(conn, :index, task_assignments: task_assignments)
  end

  def show(conn, %{"id" => id}) do
    task_assignment = Activities.get_task_assignment!(id)
    render(conn, :show, task_assignment: task_assignment)
  end

  def update(conn, %{"id" => id, "task_assignment" => task_assignment_params}) do
    task_assignment = Activities.get_task_assignment!(id)

    with {:ok, %TaskAssignment{} = task_assignment} <-
           Activities.update_task_assignment(task_assignment, task_assignment_params) do
      render(conn, :show, task_assignment: task_assignment)
    end
  end

  # Helper functions
  defp verify_task_exists(task_id) do
    case Activities.get_task(task_id) do
      {:ok, task} -> {:ok, task}
      {:error, :not_found} -> {:error, :not_found}
    end
  end

  defp verify_user_exists(user_id) do
    Gotham.Accounts.get_user(user_id)
  end

  defp verify_project_exists(project_id) do
    case Gotham.Repo.get(Gotham.Projects.Project, project_id) do
      nil -> {:error, :not_found}
      project -> {:ok, project}
    end
  end

end
