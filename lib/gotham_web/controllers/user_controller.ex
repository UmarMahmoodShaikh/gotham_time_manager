defmodule GothamWeb.UserController do
  use GothamWeb, :controller

  alias Gotham.Accounts
  alias Gotham.Accounts.User
  alias Gotham.Repo
  import Ecto.Query, warn: false
  alias Gotham.Organizations.{Team, TeamProject, ProjectTask}
  alias Gotham.Activities.{Task, TaskAssignment}

  action_fallback GothamWeb.FallbackController

  def index(conn, _params) do
    current_user = conn.assigns[:current_user]

    if current_user &&
         current_user.role_id in [Gotham.Accounts.Role.admin_id(), Gotham.Accounts.Role.hr_id()] do
      users = Accounts.list_users() |> Repo.preload(:role)
      render(conn, "index.json", users: users)
    else
      if current_user && current_user.role_id == Gotham.Accounts.Role.manager_id() do
        manager_id = current_user.id
        team_ids_query = from(t in Team, where: t.manager_id == ^manager_id, select: t.id)

        project_ids_query =
          from(tp in TeamProject,
            where: tp.team_id in subquery(team_ids_query),
            select: tp.project_id
          )

        task_ids_query =
          from(pt in ProjectTask,
            where: pt.project_id in subquery(project_ids_query),
            select: pt.task_id
          )

        assigned_user_ids_query =
          from(task in Task,
            where: task.id in subquery(task_ids_query) and not is_nil(task.assigned_user_id),
            select: task.assigned_user_id
          )

        indirect_user_ids_query =
          from(ta in TaskAssignment,
            where: ta.task_id in subquery(task_ids_query),
            select: ta.user_id
          )

        user_ids =
          (Repo.all(assigned_user_ids_query) ++ Repo.all(indirect_user_ids_query))
          |> Enum.uniq()

        users =
          from(u in User, where: u.id in ^user_ids)
          |> Repo.all()
          |> Repo.preload(:role)

        render(conn, "index.json", users: users)
      else
        conn
        |> put_status(:forbidden)
        |> json(%{errors: [%{detail: "forbidden"}]})
      end
    end
  end

#  def create(conn, %{"user" => user_params}) do
#    with {:ok, %User{} = user} <- Accounts.create_gotham_user(user_params) do
#      conn
#      |> put_status(:created)
#      |> put_resp_header("location", ~p"/api/users/#{user}")
#      |> render(:show, user: user)
#    end
#  end

  def create(conn, %{"user" => user_params}) do
    # Extract first_name and last_name (handle both atom/string keys)
    first_name = Map.get(user_params, :first_name) || Map.get(user_params, "first_name")
    last_name = Map.get(user_params, :last_name) || Map.get(user_params, "last_name")

    # Early validation
    if is_nil(first_name) or is_nil(last_name) do
      conn
      |> put_status(:bad_request)
      |> json(%{error: "first_name and last_name are required"})
    else
      # Proceed if both exist
      with {:ok, %User{} = user} <- Accounts.create_gotham_user(user_params) do
        conn
        |> put_status(:created)
        |> put_resp_header("location", ~p"/api/users/#{user}")
        |> render(:show, user: user)
      end
    end
  end

  # Fallback to accept unwrapped payloads by wrapping them under "user"
  def create(conn, params) when is_map(params) do
    create(conn, %{"user" => params})
  end

  def show(conn, %{"id" => id}) do
    user = Accounts.get_user!(id) |> Gotham.Repo.preload(:role)
    render(conn, "show.json", user: user)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    authorize_update!(conn, id)

    with {:ok, user} <- Accounts.get_user(id),
         {:ok, %User{} = user} <- Accounts.update_user(user, user_params) do
      render(conn, :show, user: user)
    end
  end

  def delete(conn, %{"id" => id}) do
    authorize_delete!(conn)

    with {:ok, %User{} = user} <- Accounts.get_user(id),
         {:ok, %User{}} <- Accounts.in_active_user(user, %{is_active: false}) do
      send_resp(conn, :no_content, "")
    end
  end

  defp authorize_delete!(conn) do
    current = conn.assigns[:current_user]

    allowed =
      current &&
        current.role_id in [Gotham.Accounts.Role.admin_id(), Gotham.Accounts.Role.hr_id()]

    if allowed, do: :ok, else: forbid(conn)
  end

  defp authorize_update!(conn, target_user_id) do
    current = conn.assigns[:current_user]

    case current do
      %{role_id: role_id} ->
        cond do
          role_id == Gotham.Accounts.Role.hr_id() -> :ok
          to_string(current.id) == to_string(target_user_id) -> :ok
          true -> forbid(conn)
        end

      _ ->
        forbid(conn)
    end
  end

  defp forbid(conn) do
    conn
    |> put_status(:forbidden)
    |> json(%{errors: [%{detail: "forbidden"}]})
    |> halt()
  end

  def update_role(conn, %{"user" => user_params}) do
    current_user = conn.assigns[:current_user]

    if current_user && current_user.role_id in [Gotham.Accounts.Role.admin_id(), Gotham.Accounts.Role.hr_id()] do
      user_to_update = Map.get(user_params, :user_id) || Map.get(user_params, "user_id")
      role_to_update = Map.get(user_params, :role_id) || Map.get(user_params, "role_id")

      user = Accounts.get_user!(user_to_update)

      case Accounts.update_user(user, %{role_id: role_to_update}) do
        {:ok, %User{} = updated_user} ->
          render(conn, "show.json", user: updated_user)

        {:error, changeset} ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{errors: [%{detail: "Failed to update role", changes: changeset_errors(changeset)}]})
      end
    else
      conn
      |> put_status(:forbidden)
      |> json(%{errors: [%{detail: "Sorry, you are not authorized to perform this action."}]})
    end
  end

  defp changeset_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end

end
