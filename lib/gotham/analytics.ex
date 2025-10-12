defmodule Gotham.Analytics do
  @moduledoc """
  Analytics and reporting functions for time tracking data.
  """

  import Ecto.Query, warn: false
  alias Gotham.Repo
  alias Gotham.TimeTracking.TimeEntry

  @doc """
  Get total hours for a user in a date range.
  """
  def get_total_hours(user_id, start_date, end_date) do
    query = from(t in TimeEntry,
      where: t.user_id == ^user_id and
             t.status in ["completed", "approved"] and
             t.clock_in >= ^DateTime.new!(start_date, ~T[00:00:00], "Etc/UTC") and
             t.clock_in <= ^DateTime.new!(end_date, ~T[23:59:59], "Etc/UTC"),
      select: coalesce(sum(coalesce(t.total_hours, 0)), 0)
    )

    Repo.one(query) || Decimal.new(0)
  end

  @doc """
  Get average daily hours for a user.
  """
  def get_average_daily_hours(user_id, start_date, end_date) do
    total_hours = get_total_hours(user_id, start_date, end_date)
    days = Date.diff(end_date, start_date) + 1

    if Decimal.gt?(total_hours, 0) do
      Decimal.div(total_hours, days) |> Decimal.to_float() |> Float.round(2)
    else
      0.0
    end
  end

  @doc """
  Get attendance rate for a user.
  """
  def get_attendance_rate(user_id, start_date, end_date) do
    # Count days with at least one time entry
    query = from(t in TimeEntry,
      where: t.user_id == ^user_id and
             t.status in ["completed", "approved"] and
             t.clock_in >= ^DateTime.new!(start_date, ~T[00:00:00], "Etc/UTC") and
             t.clock_in <= ^DateTime.new!(end_date, ~T[23:59:59], "Etc/UTC"),
      select: fragment("COUNT(DISTINCT DATE(?))", t.clock_in)
    )

    attended_days = Repo.one(query) || 0
    total_workdays = count_workdays(start_date, end_date)

    if total_workdays > 0 do
      (attended_days / total_workdays * 100) |> Float.round(2)
    else
      0.0
    end
  end

  @doc """
  Get overtime hours for a user.
  """
  def get_overtime_hours(user_id, start_date, end_date) do
    # Assuming 8 hours is standard workday
    standard_hours_per_day = 8

    query = from(t in TimeEntry,
      where: t.user_id == ^user_id and
             t.status in ["completed", "approved"] and
             t.clock_in >= ^DateTime.new!(start_date, ~T[00:00:00], "Etc/UTC") and
             t.clock_in <= ^DateTime.new!(end_date, ~T[23:59:59], "Etc/UTC"),
      group_by: fragment("DATE(?)", t.clock_in),
      select: %{
        date: fragment("DATE(?)", t.clock_in),
        daily_hours: coalesce(sum(coalesce(t.total_hours, 0)), 0)
      }
    )

    daily_totals = Repo.all(query)

    overtime_total = daily_totals
    |> Enum.reduce(Decimal.new(0), fn %{daily_hours: daily_hours}, acc ->
      if Decimal.gt?(daily_hours, standard_hours_per_day) do
        overtime = Decimal.sub(daily_hours, standard_hours_per_day)
        Decimal.add(acc, overtime)
      else
        acc
      end
    end)

    Decimal.to_float(overtime_total)
  end

  @doc """
  Get top work locations for a user.
  """
  def get_top_work_locations(user_id, start_date, end_date) do
    query = from(t in TimeEntry,
      where: t.user_id == ^user_id and
             t.status in ["completed", "approved"] and
             not is_nil(t.total_hours) and
             t.clock_in >= ^DateTime.new!(start_date, ~T[00:00:00], "Etc/UTC") and
             t.clock_in <= ^DateTime.new!(end_date, ~T[23:59:59], "Etc/UTC"),
      group_by: t.work_location,
      select: %{
        location: t.work_location,
        hours: coalesce(sum(t.total_hours), 0),
        count: count(t.id)
      },
      order_by: [desc: coalesce(sum(t.total_hours), 0)]
    )

    Repo.all(query)
  end

  @doc """
  Get daily breakdown of hours for a user.
  """
  def get_daily_breakdown(user_id, start_date, end_date) do
    query = from(t in TimeEntry,
      where: t.user_id == ^user_id and
             t.status in ["completed", "approved"] and
             not is_nil(t.total_hours) and
             t.clock_in >= ^DateTime.new!(start_date, ~T[00:00:00], "Etc/UTC") and
             t.clock_in <= ^DateTime.new!(end_date, ~T[23:59:59], "Etc/UTC"),
      group_by: fragment("DATE(?)", t.clock_in),
      select: %{
        date: fragment("DATE(?)", t.clock_in),
        total_hours: coalesce(sum(t.total_hours), 0),
        entries_count: count(t.id)
      },
      order_by: fragment("DATE(?)", t.clock_in)
    )

    Repo.all(query)
  end

  @doc """
  Get team performance data.
  """
  def get_team_performance(_team_id, start_date, end_date) do
    # Simplified for now - returns aggregated data across all users
    query = from(t in TimeEntry,
      where: t.status in ["completed", "approved"] and
             t.clock_in >= ^DateTime.new!(start_date, ~T[00:00:00], "Etc/UTC") and
             not is_nil(t.total_hours) and
             t.clock_in <= ^DateTime.new!(end_date, ~T[23:59:59], "Etc/UTC"),
      join: u in assoc(t, :user),
      group_by: [t.user_id, u.first_name, u.last_name, u.email],
      select: %{
        user_id: t.user_id,
        user_name: fragment("CONCAT(?, ' ', ?)", u.first_name, u.last_name),
        user_email: u.email,
        total_hours: coalesce(sum(t.total_hours), 0),
        total_entries: count(t.id)
      },
      order_by: [desc: coalesce(sum(t.total_hours), 0)]
    )

    Repo.all(query)
  end

  @doc """
  Get attendance trends for a user.
  """
  def get_attendance_trends(user_id, start_date, end_date) do
    query = from(t in TimeEntry,
      where: t.user_id == ^user_id and
             t.status in ["completed", "approved"] and
             not is_nil(t.total_hours) and
             t.clock_in >= ^DateTime.new!(start_date, ~T[00:00:00], "Etc/UTC") and
             t.clock_in <= ^DateTime.new!(end_date, ~T[23:59:59], "Etc/UTC"),
      group_by: [fragment("DATE_TRUNC('week', ?)", t.clock_in)],
      select: %{
        week: fragment("DATE_TRUNC('week', ?)", t.clock_in),
        total_hours: coalesce(sum(t.total_hours), 0),
        days_worked: fragment("COUNT(DISTINCT DATE(?))", t.clock_in)
      },
      order_by: fragment("DATE_TRUNC('week', ?)", t.clock_in)
    )

    Repo.all(query)
  end

  @doc """
  Get productivity insights for a user.
  """
  def get_productivity_insights(user_id, start_date, end_date) do
    # Get hourly distribution
    hourly_query = from(t in TimeEntry,
      where: t.user_id == ^user_id and
             t.status in ["completed", "approved"] and
             t.clock_in >= ^DateTime.new!(start_date, ~T[00:00:00], "Etc/UTC") and
             t.clock_in <= ^DateTime.new!(end_date, ~T[23:59:59], "Etc/UTC"),
      group_by: fragment("EXTRACT(hour FROM ?)", t.clock_in),
      select: %{
        hour: fragment("EXTRACT(hour FROM ?)", t.clock_in),
        entries_count: count(t.id)
      },
      order_by: fragment("EXTRACT(hour FROM ?)", t.clock_in)
    )

    hourly_distribution = Repo.all(hourly_query)

    # Get day of week distribution
    dow_query = from(t in TimeEntry,
      where: t.user_id == ^user_id and
             t.status in ["completed", "approved"] and
             not is_nil(t.total_hours) and
             t.clock_in >= ^DateTime.new!(start_date, ~T[00:00:00], "Etc/UTC") and
             t.clock_in <= ^DateTime.new!(end_date, ~T[23:59:59], "Etc/UTC"),
      group_by: fragment("EXTRACT(dow FROM ?)", t.clock_in),
      select: %{
        day_of_week: fragment("EXTRACT(dow FROM ?)", t.clock_in),
        total_hours: coalesce(sum(t.total_hours), 0),
        entries_count: count(t.id)
      },
      order_by: fragment("EXTRACT(dow FROM ?)", t.clock_in)
    )

    day_distribution = Repo.all(dow_query)

    %{
      hourly_distribution: hourly_distribution,
      day_of_week_distribution: day_distribution,
      peak_productivity_hour: get_peak_hour(hourly_distribution),
      most_productive_day: get_most_productive_day(day_distribution)
    }
  end

  # Helper functions
  defp count_workdays(start_date, end_date) do
    Date.range(start_date, end_date)
    |> Enum.count(fn date ->
      Date.day_of_week(date) in [1, 2, 3, 4, 5] # Monday to Friday
    end)
  end

  defp get_peak_hour(hourly_distribution) do
    case Enum.max_by(hourly_distribution, & &1.entries_count, fn -> nil end) do
      nil -> nil
      %{hour: hour} -> hour
    end
  end

  defp get_most_productive_day(day_distribution) do
    case Enum.max_by(day_distribution, & &1.total_hours, fn -> nil end) do
      nil -> nil
      %{day_of_week: dow} ->
        case dow do
          0 -> "Sunday"
          1 -> "Monday"
          2 -> "Tuesday"
          3 -> "Wednesday"
          4 -> "Thursday"
          5 -> "Friday"
          6 -> "Saturday"
          _ -> "Unknown"
        end
    end
  end
end
