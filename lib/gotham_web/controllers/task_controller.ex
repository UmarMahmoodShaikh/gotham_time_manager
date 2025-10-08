defmodule GothamWeb.TaskController do
  use GothamWeb, :controller

  alias Gotham.Activities
  alias Gotham.Activities.Task

  action_fallback GothamWeb.FallbackController

  def index(conn, _params) do
    tasks = Activities.list_tasks()
    render(conn, :index, tasks: tasks)
  end

  def create(conn, %{"task" => task_params}) do
    alias Gotham.Accounts.Role
    current_user = conn.assigns[:current_user]

    # Check if current user is admin or manager
    if current_user && current_user.role_id in [Role.admin_id(), Role.manager_id()] do
      with {:ok, %Task{} = task} <- Activities.create_task(task_params) do
        conn
        |> put_status(:created)
        |> put_resp_header("location", ~p"/api/tasks/#{task}")
        |> render(:show, task: task)
      end
    else
      conn
      |> put_status(:forbidden)
      |> json(%{
        errors: [
          %{
            status: "403",
            title: "Forbidden",
            detail: "Only admins and managers can create tasks"
          }
        ]
      })
    end
  end

  def show(conn, %{"id" => id}) do
    task = Activities.get_task!(id)
    render(conn, :show, task: task)
  end

  def update(conn, %{"id" => id, "task" => task_params}) do
    task = Activities.get_task!(id)

    with {:ok, %Task{} = task} <- Activities.update_task(task, task_params) do
      render(conn, :show, task: task)
    end
  end

  def delete(conn, %{"id" => id}) do
    task = Activities.get_task!(id)

    with {:ok, %Task{}} <- Activities.delete_task(task) do
      send_resp(conn, :no_content, "")
    end
  end

  def billable(conn, _params) do
    conn
    |> put_status(:not_implemented)
    |> json(%{errors: [%{status: "501", title: "Not Implemented"}]})
  end

  def update_status(conn, %{"taskid" => task_id} = params) do
    alias Gotham.Accounts.Role
    current_user = conn.assigns[:current_user]

    # Check if current user is admin or manager
    if current_user && current_user.role_id in [Role.admin_id(), Role.manager_id()] do
      # Handle both single task update and array format
      task_data =
        case params do
          %{"data" => [task_data]} -> task_data
          %{"status" => status} -> %{"id" => task_id, "status" => status}
          _ -> %{"id" => task_id}
        end

      # Extract fields from the task data
      task_attrs =
        task_data
        |> Map.take(["status", "description", "title", "is_billable"])
        |> Enum.reject(fn {_k, v} -> is_nil(v) end)
        |> Enum.into(%{})

      # Validate that status is valid if provided
      if Map.has_key?(task_attrs, "status") do
        valid_statuses = ["pending", "in_progress", "done", "dismissed"]

        if task_attrs["status"] in valid_statuses do
          task = Activities.get_task!(task_id)

          with {:ok, updated_task} <- Activities.update_task(task, task_attrs) do
            render(conn, :show, task: updated_task)
          end
        else
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{
            errors: [
              %{
                status: "422",
                title: "Invalid status",
                detail: "Status must be one of: pending, in_progress, done, dismissed"
              }
            ]
          })
        end
      else
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{
          errors: [%{status: "422", title: "Missing status", detail: "Status field is required"}]
        })
      end
    else
      conn
      |> put_status(:forbidden)
      |> json(%{
        errors: [
          %{
            status: "403",
            title: "Forbidden",
            detail: "Only admins and managers can update task status"
          }
        ]
      })
    end
  end
end
