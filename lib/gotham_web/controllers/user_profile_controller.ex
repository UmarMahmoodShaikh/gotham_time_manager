defmodule GothamWeb.UserProfileController do
  use GothamWeb, :controller

  alias Gotham.Accounts
  alias Gotham.TimeTracking.Breaks

  # ============ USER PROFILE MANAGEMENT ============

  # GET /api/user/profile
  def show(conn, _params) do
    current_user = conn.assigns.current_user

    user_profile = Accounts.get_user!(current_user.id)

    conn
    |> put_status(:ok)
    |> json(%{
      data: %{
        id: user_profile.id,
        first_name: user_profile.first_name,
        last_name: user_profile.last_name,
        email: user_profile.email,
        role: %{
          id: user_profile.role_id,
          name: get_role_name(user_profile.role_id)
        },
        profile_picture: nil, # TODO: Add profile picture support
        phone: nil, # TODO: Add phone field to user schema
        department: nil, # TODO: Add department field
        job_title: nil, # TODO: Add job_title field
        hire_date: nil, # TODO: Add hire_date field
        employee_id: user_profile.id, # Using user ID as employee ID for now
        manager_id: nil, # TODO: Add manager relationship
        status: "active",
        last_login: user_profile.updated_at,
        created_at: user_profile.inserted_at
      }
    })
  end

  # PUT /api/user/profile
  def update(conn, params) do
    current_user = conn.assigns.current_user

    # Only allow certain fields to be updated by the user themselves
    allowed_fields = %{
      "first_name" => params["first_name"],
      "last_name" => params["last_name"]
    }
    |> Enum.filter(fn {_k, v} -> v != nil end)
    |> Map.new()

    case Accounts.update_user(current_user, allowed_fields) do
      {:ok, user} ->
        conn
        |> put_status(:ok)
        |> json(%{
          message: "Profile updated successfully",
          data: %{
            id: user.id,
            first_name: user.first_name,
            last_name: user.last_name,
            email: user.email
          }
        })

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{
          error: "Failed to update profile",
          details: format_errors(changeset)
        })
    end
  end

  # POST /api/user/change-password
  def change_password(conn, params) do
    current_user = conn.assigns.current_user
    current_password = Map.get(params, "current_password")
    new_password = Map.get(params, "new_password")
    confirm_password = Map.get(params, "confirm_password")

    cond do
      is_nil(current_password) or is_nil(new_password) or is_nil(confirm_password) ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "Missing required fields"})

      new_password != confirm_password ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "New password and confirmation do not match"})

      String.length(new_password) < 6 ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "Password must be at least 6 characters long"})

      not Bcrypt.verify_pass(current_password, current_user.password_hash) ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "Current password is incorrect"})

      true ->
        case Accounts.update_user(current_user, %{"password" => new_password}) do
          {:ok, _user} ->
            conn
            |> put_status(:ok)
            |> json(%{message: "Password changed successfully"})

          {:error, changeset} ->
            conn
            |> put_status(:unprocessable_entity)
            |> json(%{
              error: "Failed to change password",
              details: format_errors(changeset)
            })
        end
    end
  end

  # GET /api/user/dashboard
  def dashboard(conn, _params) do
    current_user = conn.assigns.current_user

    # Get dashboard data for the user
    today = Date.utc_today()
    start_of_week = Date.beginning_of_week(today)
    start_of_month = Date.beginning_of_month(today)

    dashboard_data = %{
      user: %{
        name: "#{current_user.first_name} #{current_user.last_name}",
        role: get_role_name(current_user.role_id)
      },
      today_status: get_today_status(current_user.id),
      week_summary: get_week_summary(current_user.id, start_of_week, today),
      month_summary: get_month_summary(current_user.id, start_of_month, today),
      recent_activities: get_recent_activities(current_user.id),
      pending_approvals: get_pending_approvals_count(current_user)
    }

    conn
    |> put_status(:ok)
    |> json(%{data: dashboard_data})
  end

  # ============ BREAK MANAGEMENT ============

  # POST /api/user/breaks/start
  def start_break(conn, params) do
    current_user = conn.assigns.current_user
    break_type = Map.get(params, "break_type", "regular") # regular, lunch, emergency

    case Breaks.start_break(current_user.id, break_type) do
      {:ok, break_entry} ->
        conn
        |> put_status(:created)
        |> json(%{
          message: "Break started successfully",
          data: %{
            id: break_entry.id,
            user_id: break_entry.user_id,
            break_type: break_entry.break_type,
            start_time: break_entry.start_time,
            status: "active"
          }
        })

      {:error, :already_on_break} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "User is already on a break"})

      {:error, :not_clocked_in} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "Must be clocked in to take a break"})

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{
          error: "Failed to start break",
          details: format_errors(changeset)
        })
    end
  end

  # POST /api/user/breaks/end
  def end_break(conn, _params) do
    current_user = conn.assigns.current_user

    case Breaks.end_break(current_user.id) do
      {:ok, break_entry} ->
        conn
        |> put_status(:ok)
        |> json(%{
          message: "Break ended successfully",
          data: %{
            id: break_entry.id,
            break_type: break_entry.break_type,
            start_time: break_entry.start_time,
            end_time: break_entry.end_time,
            duration_minutes: break_entry.duration_minutes,
            status: "completed"
          }
        })

      {:error, :no_active_break} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "No active break to end"})

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{
          error: "Failed to end break",
          details: format_errors(changeset)
        })
    end
  end

  # GET /api/user/breaks/status
  def break_status(conn, _params) do
    current_user = conn.assigns.current_user

    case Breaks.get_active_break(current_user.id) do
      nil ->
        conn
        |> put_status(:ok)
        |> json(%{
          status: "not_on_break",
          active_break: nil
        })

      break_entry ->
        duration_so_far = DateTime.diff(DateTime.utc_now(), break_entry.start_time, :second) |> div(60)

        conn
        |> put_status(:ok)
        |> json(%{
          status: "on_break",
          active_break: %{
            id: break_entry.id,
            break_type: break_entry.break_type,
            start_time: break_entry.start_time,
            duration_minutes: duration_so_far
          }
        })
    end
  end

  # GET /api/user/breaks/history
  def break_history(conn, params) do
    current_user = conn.assigns.current_user
    page = Map.get(params, "page", "1") |> String.to_integer()
    limit = Map.get(params, "limit", "20") |> String.to_integer()

    start_date = case Map.get(params, "start_date") do
      nil -> nil
      date_str -> Date.from_iso8601!(date_str) |> DateTime.new!(~T[00:00:00], "Etc/UTC")
    end

    end_date = case Map.get(params, "end_date") do
      nil -> nil
      date_str -> Date.from_iso8601!(date_str) |> DateTime.new!(~T[23:59:59], "Etc/UTC")
    end

    filters = %{
      user_id: current_user.id,
      page: page,
      limit: limit,
      start_date: start_date,
      end_date: end_date
    }

    {break_entries, meta} = Breaks.list_break_history(filters)

    conn
    |> put_status(:ok)
    |> json(%{
      data: break_entries,
      meta: meta
    })
  end

  # GET /api/user/breaks/summary
  def break_summary(conn, params) do
    current_user = conn.assigns.current_user
    summary_date = case Map.get(params, "date") do
      nil -> Date.utc_today()
      date_str -> Date.from_iso8601!(date_str)
    end

    summary = Breaks.get_daily_break_summary(current_user.id, summary_date)

    conn
    |> put_status(:ok)
    |> json(%{data: summary})
  end

  # ============ EXISTING HELPER FUNCTIONS ============
  # Helper functions
  defp get_role_name(role_id) do
    case role_id do
      1 -> "Employee"
      2 -> "Manager"
      3 -> "Admin"
      _ -> "Unknown"
    end
  end

  defp get_today_status(user_id) do
    alias Gotham.TimeTracking

    case TimeTracking.get_active_entry(user_id) do
      nil -> %{status: "not_clocked_in", clock_in_time: nil}
      entry -> %{
        status: "clocked_in",
        clock_in_time: entry.clock_in,
        location: entry.work_location
      }
    end
  end

  defp get_week_summary(user_id, start_date, end_date) do
    alias Gotham.Analytics

    total_hours = Analytics.get_total_hours(user_id, start_date, end_date)

    %{
      total_hours: Decimal.to_float(total_hours),
      target_hours: 40.0,
      days_worked: count_work_days(user_id, start_date, end_date)
    }
  end

  defp get_month_summary(user_id, start_date, end_date) do
    alias Gotham.Analytics

    total_hours = Analytics.get_total_hours(user_id, start_date, end_date)

    %{
      total_hours: Decimal.to_float(total_hours),
      target_hours: 160.0,
      attendance_rate: Analytics.get_attendance_rate(user_id, start_date, end_date)
    }
  end

  defp get_recent_activities(user_id) do
    alias Gotham.TimeTracking

    TimeTracking.list_time_entries(user_id)
    |> Enum.take(5)
    |> Enum.map(fn entry ->
      %{
        date: entry.clock_in |> DateTime.to_date(),
        action: (if entry.clock_out, do: "Clock Out", else: "Clock In"),
        time: (if entry.clock_out, do: entry.clock_out, else: entry.clock_in),
        location: entry.work_location,
        hours: entry.total_hours
      }
    end)
  end

  defp get_pending_approvals_count(user) do
    if user.role_id in [2, 3] do
      # For managers/admins, show count of pending approvals
      alias Gotham.TimeTracking

      {entries, _meta} = TimeTracking.list_pending_approvals(%{
        status: "pending",
        page: 1,
        limit: 1000
      })

      length(entries)
    else
      0
    end
  end

  defp count_work_days(user_id, start_date, end_date) do
    alias Gotham.TimeTracking

    entries = TimeTracking.get_entries_by_date_range(user_id,
      DateTime.new!(start_date, ~T[00:00:00], "Etc/UTC"),
      DateTime.new!(end_date, ~T[23:59:59], "Etc/UTC")
    )

    entries
    |> Enum.map(&(&1.clock_in |> DateTime.to_date()))
    |> Enum.uniq()
    |> length()
  end

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
