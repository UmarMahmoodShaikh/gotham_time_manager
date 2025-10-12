defmodule GothamWeb.SettingsController do
  use GothamWeb, :controller

  alias Gotham.Settings

  # GET /api/settings/profile
  def profile(conn, _params) do
    current_user = conn.assigns.current_user

    profile_settings = Settings.get_user_profile_settings(current_user.id)

    conn
    |> put_status(:ok)
    |> json(%{
      data: profile_settings
    })
  end

  # PUT /api/settings/profile
  def update_profile(conn, params) do
    current_user = conn.assigns.current_user

    case Settings.update_user_profile_settings(current_user.id, params) do
      {:ok, settings} ->
        conn
        |> put_status(:ok)
        |> json(%{
          message: "Profile settings updated successfully",
          data: settings
        })

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{
          error: "Failed to update profile settings",
          details: format_errors(changeset)
        })
    end
  end

  # GET /api/settings/notifications
  def notifications(conn, _params) do
    current_user = conn.assigns.current_user

    notification_settings = Settings.get_notification_settings(current_user.id)

    conn
    |> put_status(:ok)
    |> json(%{
      data: notification_settings
    })
  end

  # PUT /api/settings/notifications
  def update_notifications(conn, params) do
    current_user = conn.assigns.current_user

    case Settings.update_notification_settings(current_user.id, params) do
      {:ok, settings} ->
        conn
        |> put_status(:ok)
        |> json(%{
          message: "Notification settings updated successfully",
          data: settings
        })

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{
          error: "Failed to update notification settings",
          details: format_errors(changeset)
        })
    end
  end

  # GET /api/settings/work-preferences
  def work_preferences(conn, _params) do
    current_user = conn.assigns.current_user

    work_preferences = Settings.get_work_preferences(current_user.id)

    conn
    |> put_status(:ok)
    |> json(%{
      data: work_preferences
    })
  end

  # PUT /api/settings/work-preferences
  def update_work_preferences(conn, params) do
    current_user = conn.assigns.current_user

    case Settings.update_work_preferences(current_user.id, params) do
      {:ok, preferences} ->
        conn
        |> put_status(:ok)
        |> json(%{
          message: "Work preferences updated successfully",
          data: preferences
        })

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{
          error: "Failed to update work preferences",
          details: format_errors(changeset)
        })
    end
  end

  # GET /api/settings/system (Admin only)
  def system(conn, _params) do
    current_user = conn.assigns.current_user

    if current_user.role_id != 3 do
      conn
      |> put_status(:forbidden)
      |> json(%{error: "Access denied"})
    else
      system_settings = Settings.get_system_settings()

      conn
      |> put_status(:ok)
      |> json(%{
        data: system_settings
      })
    end
  end

  # PUT /api/settings/system (Admin only)
  def update_system(conn, params) do
    current_user = conn.assigns.current_user

    if current_user.role_id != 3 do
      conn
      |> put_status(:forbidden)
      |> json(%{error: "Access denied"})
    else
      case Settings.update_system_settings(params) do
        {:ok, settings} ->
          conn
          |> put_status(:ok)
          |> json(%{
            message: "System settings updated successfully",
            data: settings
          })

        {:error, changeset} ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{
            error: "Failed to update system settings",
            details: format_errors(changeset)
          })
      end
    end
  end

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
