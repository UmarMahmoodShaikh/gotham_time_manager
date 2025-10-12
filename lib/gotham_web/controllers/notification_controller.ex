defmodule GothamWeb.NotificationController do
  use GothamWeb, :controller

  # GET /api/notifications
  def index(conn, params) do
    current_user = conn.assigns.current_user
    page = Map.get(params, "page", "1") |> String.to_integer()
    limit = Map.get(params, "limit", "20") |> String.to_integer()
    unread_only = Map.get(params, "unread_only", "false") == "true"

    # Mock notifications for now
    notifications = get_mock_notifications(current_user, unread_only)

    # Paginate
    offset = (page - 1) * limit
    paginated_notifications = notifications |> Enum.slice(offset, limit)

    meta = %{
      current_page: page,
      per_page: limit,
      total_count: length(notifications),
      total_pages: ceil(length(notifications) / limit)
    }

    conn
    |> put_status(:ok)
    |> json(%{
      data: paginated_notifications,
      meta: meta
    })
  end

  # GET /api/notifications/unread-count
  def unread_count(conn, _params) do
    current_user = conn.assigns.current_user

    # Mock unread count
    unread_count = get_mock_notifications(current_user, true) |> length()

    conn
    |> put_status(:ok)
    |> json(%{
      unread_count: unread_count
    })
  end

  # PUT /api/notifications/:id/read
  def mark_as_read(conn, %{"id" => notification_id}) do
    # Mock marking as read
    conn
    |> put_status(:ok)
    |> json(%{
      message: "Notification marked as read",
      notification_id: notification_id
    })
  end

  # PUT /api/notifications/mark-all-read
  def mark_all_as_read(conn, _params) do
    # Mock marking all as read
    conn
    |> put_status(:ok)
    |> json(%{
      message: "All notifications marked as read"
    })
  end

  # DELETE /api/notifications/:id
  def delete(conn, %{"id" => notification_id}) do
    # Mock deletion
    conn
    |> put_status(:ok)
    |> json(%{
      message: "Notification deleted",
      notification_id: notification_id
    })
  end

  # POST /api/notifications/preferences
  def update_preferences(conn, params) do
    # Mock updating notification preferences
    preferences = %{
      email_notifications: Map.get(params, "email_notifications", true),
      push_notifications: Map.get(params, "push_notifications", true),
      approval_notifications: Map.get(params, "approval_notifications", true),
      overtime_alerts: Map.get(params, "overtime_alerts", true),
      reminder_notifications: Map.get(params, "reminder_notifications", true)
    }

    conn
    |> put_status(:ok)
    |> json(%{
      message: "Notification preferences updated",
      preferences: preferences
    })
  end

  # Helper function to generate mock notifications
  defp get_mock_notifications(user, unread_only) do
    base_notifications = [
      %{
        id: 1,
        title: "Time Entry Approved",
        message: "Your overtime request for October 10th has been approved",
        type: "approval",
        read: false,
        created_at: DateTime.utc_now() |> DateTime.add(-3600, :second),
        priority: "medium"
      },
      %{
        id: 2,
        title: "Clock Out Reminder",
        message: "Don't forget to clock out at the end of your shift",
        type: "reminder",
        read: true,
        created_at: DateTime.utc_now() |> DateTime.add(-7200, :second),
        priority: "low"
      },
      %{
        id: 3,
        title: "Payroll Generated",
        message: "Your payroll for October has been processed",
        type: "payroll",
        read: false,
        created_at: DateTime.utc_now() |> DateTime.add(-86400, :second),
        priority: "high"
      },
      %{
        id: 4,
        title: "New Team Assignment",
        message: "You have been assigned to the Wayne Enterprises project",
        type: "assignment",
        read: user.role_id == 1, # Unread for employees
        created_at: DateTime.utc_now() |> DateTime.add(-172800, :second),
        priority: "medium"
      },
      %{
        id: 5,
        title: "Schedule Updated",
        message: "Your work schedule for next week has been updated",
        type: "schedule",
        read: false,
        created_at: DateTime.utc_now() |> DateTime.add(-259200, :second),
        priority: "medium"
      }
    ]

    if unread_only do
      Enum.filter(base_notifications, & &1.read == false)
    else
      base_notifications
    end
  end
end
