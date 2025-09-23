defmodule GothamTimeManagerWeb.TaskController do
  use GothamTimeManagerWeb, :controller

  alias GothamTimeManager.Repo
  alias GothamTimeManager.Tasks
  alias GothamTimeManager.Tasks.Task

  action_fallback GothamTimeManagerWeb.FallbackController

  # GET /api/tasks
  def index(conn, _params) do
    tasks = Tasks.list_tasks()
    tasks_data = Enum.map(tasks, &task_to_map/1)
    json(conn, %{data: tasks_data})
  end

  # POST /api/tasks
  def create(conn, %{"task" => task_params}) do
    user_ids = Map.get(task_params, "user_ids", [])
    task_params = normalize_status_param(task_params)

    with {:ok, %Task{} = task} <- Tasks.create_task(task_params),
         {:ok, %Task{} = task} <- Tasks.put_assoc_users(task, user_ids) do
      json(conn, %{data: task_to_map(task)})
    else
      {:error, :user_not_found, missing_ids} ->
        conn
        |> put_status(:not_found)
        |> json(%{message: "User(s) not found", missing_ids: missing_ids})
      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_status(400)
        |> json(%{errors: Ecto.Changeset.traverse_errors(changeset, &translate_error/1)})
    end
  end

  # GET /api/tasks/:id
  def show(conn, %{"id" => id}) do
    case Tasks.get_task(id) do
      nil ->
        conn
        |> put_status(404)
        |> json(%{message: "Task not found"})
      task ->
        json(conn, %{data: task_to_map(task)})
    end
  end

  # PUT /api/tasks/:id
  def update(conn, %{"id" => id, "task" => task_params}) do
    case Repo.get(Task, id) do
      nil ->
        conn
        |> put_status(404)
        |> json(%{message: "Task not found"})
      task ->
        user_ids = Map.get(task_params, "user_ids", [])
        task_params = normalize_status_param(task_params)

        with {:ok, updated_task} <- Tasks.update_task(task, task_params),
             {:ok, updated_task} <- Tasks.put_assoc_users(updated_task, user_ids) do
          json(conn, %{data: task_to_map(updated_task)})
        else
          {:error, :user_not_found, missing_ids} ->
            conn
            |> put_status(:not_found)
            |> json(%{message: "User(s) not found", missing_ids: missing_ids})

          {:error, %Ecto.Changeset{} = changeset} ->
            conn
            |> put_status(:unprocessable_entity)
            |> json(%{errors: Ecto.Changeset.traverse_errors(changeset, &translate_error/1)})
        end
    end
  end

  # DELETE /api/tasks/:id
  def delete(conn, %{"id" => id}) do
    case Tasks.get_task(id) do
      nil ->
        conn
        |> put_status(404)
        |> json(%{message: "Task not found"})
      task ->
        with {:ok, %Task{}} <- Tasks.delete_task(task) do
          send_resp(conn, 204, "")
        end
    end
  end

  # GET /api/tasks/users/:user_id
  def by_user(conn, %{"user_id" => user_id}) do
    tasks = Tasks.list_tasks_for_user(user_id)
    tasks_data = Enum.map(tasks, &task_to_map/1)
    if tasks_data == [] do
      conn
      |> put_status(404)
      |> json(%{message: "No tasks found for this user"})
    else
      json(conn, %{data: tasks_data})
    end
  end

  # Map task to JSON safely
  defp task_to_map(%Task{} = task) do
    %{
      id: task.id,
      title: task.title || "",
      description: task.description || "",
      status: task.status,
      status_name: Task.status_name(task),
      user_ids: Enum.map(task.users || [], & &1.id)
    }
  end

  # Translate Ecto changeset errors into readable messages
  defp translate_error({msg, opts}) do
    Enum.reduce(opts, msg, fn {key, val}, acc ->
      String.replace(acc, "%{#{key}}", safe_to_string(val))
    end)
  end

  # Accept either status or status_id from clients
  defp normalize_status_param(params) when is_map(params) do
    cond do
      Map.has_key?(params, "status") -> params
      Map.has_key?(params, "status_id") ->
        params
        |> Map.put("status", params["status_id"])
        |> Map.delete("status_id")
      true -> params
    end
  end

  defp safe_to_string(val) when is_binary(val), do: val
  defp safe_to_string(val) when is_integer(val) or is_float(val), do: to_string(val)
  defp safe_to_string(val) when is_atom(val), do: Atom.to_string(val)
  defp safe_to_string(val) when is_list(val) do
    val
    |> Enum.map(&safe_to_string/1)
    |> Enum.join(", ")
  end
  defp safe_to_string(val), do: inspect(val)
end
