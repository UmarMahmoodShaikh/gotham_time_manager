defmodule GothamWeb.AnalyticsController do
  use GothamWeb, :controller

  alias Gotham.Analytics

  # GET /api/analytics/dashboard
  def dashboard(conn, params) do
    current_user = conn.assigns.current_user

    # Get date range from params or default to current month
    {start_date, end_date} = get_date_range(params)

    # Only managers and admins can see team analytics
    user_id = if current_user.role_id in [2, 3] do
      Map.get(params, "user_id")
    else
      current_user.id
    end

    analytics_data = %{
      total_hours: Analytics.get_total_hours(user_id, start_date, end_date),
      average_daily_hours: Analytics.get_average_daily_hours(user_id, start_date, end_date),
      attendance_rate: Analytics.get_attendance_rate(user_id, start_date, end_date),
      overtime_hours: Analytics.get_overtime_hours(user_id, start_date, end_date),
      top_locations: Analytics.get_top_work_locations(user_id, start_date, end_date),
      daily_breakdown: Analytics.get_daily_breakdown(user_id, start_date, end_date)
    }

    conn
    |> put_status(:ok)
    |> json(%{
      data: analytics_data,
      period: %{
        start_date: start_date,
        end_date: end_date
      }
    })
  end

  # GET /api/analytics/team-performance
  def team_performance(conn, params) do
    current_user = conn.assigns.current_user

    # Only managers and admins can access team performance
    if current_user.role_id not in [2, 3] do
      conn
      |> put_status(:forbidden)
      |> json(%{error: "Access denied"})
    else
      {start_date, end_date} = get_date_range(params)
      team_id = Map.get(params, "team_id")

      performance_data = Analytics.get_team_performance(team_id, start_date, end_date)

      conn
      |> put_status(:ok)
      |> json(%{
        data: performance_data,
        period: %{
          start_date: start_date,
          end_date: end_date
        }
      })
    end
  end

  # GET /api/analytics/attendance-trends
  def attendance_trends(conn, params) do
    current_user = conn.assigns.current_user

    {start_date, end_date} = get_date_range(params)

    user_id = if current_user.role_id in [2, 3] do
      Map.get(params, "user_id")
    else
      current_user.id
    end

    trends_data = Analytics.get_attendance_trends(user_id, start_date, end_date)

    conn
    |> put_status(:ok)
    |> json(%{
      data: trends_data,
      period: %{
        start_date: start_date,
        end_date: end_date
      }
    })
  end

  # GET /api/analytics/productivity-insights
  def productivity_insights(conn, params) do
    current_user = conn.assigns.current_user

    {start_date, end_date} = get_date_range(params)

    user_id = if current_user.role_id in [2, 3] do
      Map.get(params, "user_id")
    else
      current_user.id
    end

    insights_data = Analytics.get_productivity_insights(user_id, start_date, end_date)

    conn
    |> put_status(:ok)
    |> json(%{
      data: insights_data,
      period: %{
        start_date: start_date,
        end_date: end_date
      }
    })
  end

  defp get_date_range(params) do
    start_date = case Map.get(params, "start_date") do
      nil ->
        Date.utc_today() |> Date.beginning_of_month()
      date_string ->
        case Date.from_iso8601(date_string) do
          {:ok, date} -> date
          _ -> Date.utc_today() |> Date.beginning_of_month()
        end
    end

    end_date = case Map.get(params, "end_date") do
      nil ->
        Date.utc_today() |> Date.end_of_month()
      date_string ->
        case Date.from_iso8601(date_string) do
          {:ok, date} -> date
          _ -> Date.utc_today() |> Date.end_of_month()
        end
    end

    {start_date, end_date}
  end
end
