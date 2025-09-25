defmodule GothamTimeManagerWeb.UserController do
  use GothamTimeManagerWeb, :controller
  alias GothamTimeManager.Repo
  alias GothamTimeManager.Accounts
  alias GothamTimeManager.Accounts.User

  action_fallback GothamTimeManagerWeb.FallbackController

  def index(conn, _params) do
    users = Accounts.list_users()
    render(conn, :index, users: users)
  end

  def create(conn, %{"user" => user_params}) do
    with {:ok, %User{} = user} <- Accounts.create_user(user_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/users/#{user}")
      |> render(:show, user: user)
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_status(400)
        |> json(%{errors: Ecto.Changeset.traverse_errors(changeset, &translate_error/1)})
    end
  end

  def show(conn, %{"id" => id}) do
    case Repo.get(User, id) do
      nil ->
        conn
        |> put_status(404)
        |> json(%{message: "User not found"})
      user ->
        render(conn, :show, user: user)
    end
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    case Repo.get(User, id) do
      nil ->
        conn
        |> put_status(404)
        |> json(%{message: "User not found"})
      user ->
        with {:ok, %User{} = user} <- Accounts.update_user(user, user_params) do
          render(conn, :show, user: user)
        else
          {:error, %Ecto.Changeset{} = changeset} ->
            conn
            |> put_status(400)
            |> json(%{errors: Ecto.Changeset.traverse_errors(changeset, &translate_error/1)})
        end
    end
  end

  def delete(conn, %{"id" => id}) do
    case Repo.get(User, id) do
      nil ->
        conn
        |> put_status(404)
        |> json(%{message: "User not found"})
      user ->
        with {:ok, %User{}} <- Accounts.delete_user(user) do
          send_resp(conn, 204, "User Deleted Successfully")
        end
    end
  end

  defp translate_error({msg, opts}) do
    Enum.reduce(opts, msg, fn {key, val}, acc ->
      String.replace(acc, "%{#{key}}", safe_to_string(val))
    end)
  end

  defp safe_to_string(val) when is_binary(val), do: val
  defp safe_to_string(val) when is_integer(val) or is_float(val), do: to_string(val)
  defp safe_to_string(val) when is_atom(val), do: Atom.to_string(val)
  defp safe_to_string(val) when is_list(val), do: val |> Enum.map(&safe_to_string/1) |> Enum.join(", ")
  defp safe_to_string(val), do: inspect(val)
end
