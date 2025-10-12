defmodule Gotham.Reports do
  @moduledoc """
  Report generation functions for timesheet, attendance, payroll, and overtime reports.
  """

  import Ecto.Query, warn: false
  alias Gotham.Repo
  alias Gotham.TimeTracking.TimeEntry

  @doc """
  Generate timesheet report for a user.
  """
  def generate_timesheet(user_id, start_date, end_date) do
    query = from(t in TimeEntry,
      where: t.user_id == ^user_id and
             t.status in ["completed", "approved"] and
             t.clock_in >= ^DateTime.new!(start_date, ~T[00:00:00], "Etc/UTC") and
             t.clock_in <= ^DateTime.new!(end_date, ~T[23:59:59], "Etc/UTC"),
      join: u in assoc(t, :user),
      select: %{
        id: t.id,
        user_name: fragment("CONCAT(?, ' ', ?)", u.first_name, u.last_name),
        date: fragment("DATE(?)", t.clock_in),
        clock_in: t.clock_in,
        clock_out: t.clock_out,
        total_hours: t.total_hours,
        work_location: t.work_location,
        notes: t.notes,
        status: t.status,
        is_manual: t.is_manual
      },
      order_by: [desc: t.clock_in]
    )

    entries = Repo.all(query)

    summary = %{
      total_entries: length(entries),
      total_hours: entries |> Enum.map(&(&1.total_hours || Decimal.new(0))) |> Enum.reduce(Decimal.new(0), &Decimal.add/2),
      regular_hours: calculate_regular_hours(entries),
      overtime_hours: calculate_overtime_hours(entries)
    }

    %{
      entries: entries,
      summary: summary
    }
  end

  @doc """
  Generate attendance report for a team.
  """
  def generate_attendance_report(team_id, start_date, end_date) do
    # For now, generate report for all users since team structure is not fully implemented
    query = from(t in TimeEntry,
      where: t.status in ["completed", "approved"] and
             t.clock_in >= ^DateTime.new!(start_date, ~T[00:00:00], "Etc/UTC") and
             t.clock_in <= ^DateTime.new!(end_date, ~T[23:59:59], "Etc/UTC"),
      join: u in assoc(t, :user),
      group_by: [t.user_id, u.first_name, u.last_name, u.email],
      select: %{
        user_id: t.user_id,
        user_name: fragment("CONCAT(?, ' ', ?)", u.first_name, u.last_name),
        user_email: u.email,
        total_days_worked: fragment("COUNT(DISTINCT DATE(?))", t.clock_in),
        total_hours: sum(t.total_hours),
        average_daily_hours: fragment("ROUND(CAST(? AS numeric) / NULLIF(COUNT(DISTINCT DATE(?)), 0), 2)", sum(t.total_hours), t.clock_in)
      },
      order_by: [desc: sum(t.total_hours)]
    )

    Repo.all(query)
  end

  @doc """
  Generate payroll report.
  """
  def generate_payroll_report(start_date, end_date) do
    query = from(t in TimeEntry,
      where: t.status == "approved" and
             t.clock_in >= ^DateTime.new!(start_date, ~T[00:00:00], "Etc/UTC") and
             t.clock_in <= ^DateTime.new!(end_date, ~T[23:59:59], "Etc/UTC"),
      join: u in assoc(t, :user),
      group_by: [t.user_id, u.first_name, u.last_name, u.email],
      select: %{
        user_id: t.user_id,
        user_name: fragment("CONCAT(?, ' ', ?)", u.first_name, u.last_name),
        user_email: u.email,
        total_hours: sum(t.total_hours),
        regular_hours: fragment("LEAST(?, 160)", sum(t.total_hours)), # Assuming 160 hours per month is regular
        overtime_hours: fragment("GREATEST(0, ? - 160)", sum(t.total_hours)),
        gross_pay: fragment("(LEAST(?, 160) * 25) + (GREATEST(0, ? - 160) * 37.5)", sum(t.total_hours), sum(t.total_hours)) # $25/hour regular, $37.5 overtime
      },
      order_by: [desc: sum(t.total_hours)]
    )

    Repo.all(query)
  end

  @doc """
  Generate overtime report.
  """
  def generate_overtime_report(_team_id, start_date, end_date) do
    # Group by user and date to calculate daily overtime
    query = from(t in TimeEntry,
      where: t.status in ["completed", "approved"] and
             t.clock_in >= ^DateTime.new!(start_date, ~T[00:00:00], "Etc/UTC") and
             t.clock_in <= ^DateTime.new!(end_date, ~T[23:59:59], "Etc/UTC"),
      join: u in assoc(t, :user),
      group_by: [t.user_id, u.first_name, u.last_name, fragment("DATE(?)", t.clock_in)],
      select: %{
        user_id: t.user_id,
        user_name: fragment("CONCAT(?, ' ', ?)", u.first_name, u.last_name),
        date: fragment("DATE(?)", t.clock_in),
        daily_hours: sum(t.total_hours),
        overtime_hours: fragment("GREATEST(0, ? - 8)", sum(t.total_hours)) # Over 8 hours is overtime
      },
      having: fragment("? > 8", sum(t.total_hours)),
      order_by: [desc: fragment("DATE(?)", t.clock_in)]
    )

    Repo.all(query)
  end

  @doc """
  Convert timesheet data to CSV format.
  """
  def timesheet_to_csv(%{entries: entries}) do
    headers = ["Date", "Clock In", "Clock Out", "Total Hours", "Work Location", "Notes", "Status", "Manual Entry"]

    csv_rows = [headers | Enum.map(entries, fn entry ->
      [
        to_string(entry.date),
        format_datetime(entry.clock_in),
        format_datetime(entry.clock_out),
        to_string(entry.total_hours || "0"),
        entry.work_location || "",
        entry.notes || "",
        entry.status,
        to_string(entry.is_manual)
      ]
    end)]

    csv_rows
    |> Enum.map(&Enum.join(&1, ","))
    |> Enum.join("\n")
  end

  @doc """
  Convert attendance data to CSV format.
  """
  def attendance_to_csv(attendance_data) do
    headers = ["Employee Name", "Email", "Days Worked", "Total Hours", "Average Daily Hours"]

    csv_rows = [headers | Enum.map(attendance_data, fn entry ->
      [
        entry.user_name,
        entry.user_email,
        to_string(entry.total_days_worked),
        to_string(entry.total_hours || "0"),
        to_string(entry.average_daily_hours || "0")
      ]
    end)]

    csv_rows
    |> Enum.map(&Enum.join(&1, ","))
    |> Enum.join("\n")
  end

  @doc """
  Convert payroll data to CSV format.
  """
  def payroll_to_csv(payroll_data) do
    headers = ["Employee Name", "Email", "Total Hours", "Regular Hours", "Overtime Hours", "Gross Pay"]

    csv_rows = [headers | Enum.map(payroll_data, fn entry ->
      [
        entry.user_name,
        entry.user_email,
        to_string(entry.total_hours || "0"),
        to_string(entry.regular_hours || "0"),
        to_string(entry.overtime_hours || "0"),
        to_string(entry.gross_pay || "0")
      ]
    end)]

    csv_rows
    |> Enum.map(&Enum.join(&1, ","))
    |> Enum.join("\n")
  end

  @doc """
  Convert overtime data to CSV format.
  """
  def overtime_to_csv(overtime_data) do
    headers = ["Employee Name", "Date", "Daily Hours", "Overtime Hours"]

    csv_rows = [headers | Enum.map(overtime_data, fn entry ->
      [
        entry.user_name,
        to_string(entry.date),
        to_string(entry.daily_hours || "0"),
        to_string(entry.overtime_hours || "0")
      ]
    end)]

    csv_rows
    |> Enum.map(&Enum.join(&1, ","))
    |> Enum.join("\n")
  end

  @doc """
  Convert timesheet data to PDF format (placeholder).
  """
  def timesheet_to_pdf(_timesheet_data) do
    # This would require a PDF library like PuppeteerPdf or similar
    # For now, return a placeholder
    "PDF generation not implemented yet. Please use CSV format."
  end

  # Helper functions
  defp calculate_regular_hours(entries) do
    # Assuming 8 hours per day is regular
    entries
    |> Enum.group_by(& &1.date)
    |> Enum.reduce(Decimal.new(0), fn {_date, day_entries}, acc ->
      daily_total = day_entries
      |> Enum.map(&(&1.total_hours || Decimal.new(0)))
      |> Enum.reduce(Decimal.new(0), &Decimal.add/2)

      regular_daily = if Decimal.gt?(daily_total, 8), do: Decimal.new(8), else: daily_total
      Decimal.add(acc, regular_daily)
    end)
  end

  defp calculate_overtime_hours(entries) do
    # Assuming anything over 8 hours per day is overtime
    entries
    |> Enum.group_by(& &1.date)
    |> Enum.reduce(Decimal.new(0), fn {_date, day_entries}, acc ->
      daily_total = day_entries
      |> Enum.map(&(&1.total_hours || Decimal.new(0)))
      |> Enum.reduce(Decimal.new(0), &Decimal.add/2)

      overtime_daily = if Decimal.gt?(daily_total, 8) do
        Decimal.sub(daily_total, 8)
      else
        Decimal.new(0)
      end

      Decimal.add(acc, overtime_daily)
    end)
  end

  defp format_datetime(nil), do: ""
  defp format_datetime(datetime) do
    datetime
    |> DateTime.to_string()
    |> String.slice(0, 19) # Remove timezone info for CSV
  end
end
