defmodule GothamTimeManager.Tasks do
  import Ecto.Query, warn: false
  alias GothamTimeManager.Repo
  alias GothamTimeManager.Tasks.Task
  alias GothamTimeManager.Accounts.User

  # List all tasks
  def list_tasks do
    Repo.all(Task) |> Repo.preload(:users)
  end

  # Get single task by id
  def get_task(id) do
    Repo.get(Task, id) |> Repo.preload(:users)
  end

  # Create a task with optional user_ids
  def create_task(attrs) do
    %Task{}
    |> Task.changeset(attrs)
    |> Repo.insert()
  end

  def put_assoc_users(%Task{} = task, user_ids) when is_list(user_ids) do
    users = Repo.all(from u in GothamTimeManager.Accounts.User, where: u.id in ^user_ids)
    missing_ids = user_ids -- Enum.map(users, & &1.id)

    if missing_ids != [] do
      {:error, :user_not_found, missing_ids}
    else
      timestamp = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

      entries =
        Enum.map(users, fn user ->
          %{
            task_id: task.id,
            user_id: user.id,
            inserted_at: timestamp,
            updated_at: timestamp
          }
        end)

      Repo.insert_all("tasks_users", entries)
      {:ok, Repo.preload(task, :users)}  # Return task with users
    end
  end


  # Update a task with optional user_ids
  def update_task(%Task{} = task, attrs) do
    task
    |> Task.changeset(attrs)
    |> Repo.update()
  end

  # Delete a task
  def delete_task(%Task{} = task) do
    Repo.delete(task)
  end

  # List tasks for a given user
  def list_tasks_for_user(user_id) do
    case Repo.get(User, user_id) do
      nil -> []
      user -> Repo.preload(user, :tasks).tasks
    end
  end
end

