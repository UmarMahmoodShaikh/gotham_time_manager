defmodule GothamWeb.PermissionController do
  use GothamWeb, :controller
  alias Gotham.Accounts
  action_fallback GothamWeb.FallbackController
  alias Gotham.Accounts.PermissionLevel

  def update(conn, %{"user_id" => user_id_param} = params) do
    with {managed_user_id, ""} <- Integer.parse(user_id_param),
         manager_id when not is_nil(manager_id) <- get_manager_id(conn),
         true <- PermissionLevel.valid?(params["permission_level"]),
         attrs = %{
           "permission_level" => params["permission_level"],
           "manager_id" => manager_id,
           "managed_user_id" => managed_user_id
         },
         {:ok, permission} <-
           Accounts.update_permission_for_user(manager_id, managed_user_id, attrs) do
      conn
      |> put_status(:ok)
      |> render("show.json", permission: permission)
    else
      false ->
        conn
        |> put_status(:bad_request)
        |> json(%{
          error: "Invalid permission_level. Allowed: #{inspect(PermissionLevel.levels())}"
        })

      :error ->
        conn |> put_status(:bad_request) |> json(%{error: "Invalid user_id"})

      nil ->
        conn |> put_status(:unauthorized) |> json(%{error: "Not authenticated"})

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  def delete(conn, %{"user_id" => managed_user_id}) do
    manager_id = get_manager_id(conn)

    with {:ok, _permission} <- Accounts.revoke_permission(manager_id, managed_user_id) do
      conn
      |> put_status(:ok)
      |> json(%{message: "Permission revoked", managed_user_id: managed_user_id})
    end
  end

  defp get_manager_id(conn) do
    if user = conn.assigns[:current_user] do
      user.id
    else
      nil
    end
  end
end
