defmodule GothamWeb.ReportsController do
  use GothamWeb, :controller

  alias Gotham.Reports

  # GET /api/reports/timesheet
  def timesheet(conn, params) do
    current_user = conn.assigns.current_user

    {start_date, end_date} = get_date_range(params)

    user_id = if current_user.role_id in [2, 3] do
      Map.get(params, "user_id", current_user.id)
    else
      current_user.id
    end

    format = Map.get(params, "format", "json")

    timesheet_data = Reports.generate_timesheet(user_id, start_date, end_date)

    case format do
      "csv" ->
        csv_content = Reports.timesheet_to_csv(timesheet_data)

        conn
        |> put_resp_content_type("text/csv")
        |> put_resp_header("content-disposition", "attachment; filename=\"timesheet_#{start_date}_#{end_date}.csv\"")
        |> send_resp(200, csv_content)

      "pdf" ->
        pdf_content = Reports.timesheet_to_pdf(timesheet_data)

        conn
        |> put_resp_content_type("application/pdf")
        |> put_resp_header("content-disposition", "attachment; filename=\"timesheet_#{start_date}_#{end_date}.pdf\"")
        |> send_resp(200, pdf_content)

      _ ->
        conn
        |> put_status(:ok)
        |> json(%{
          data: timesheet_data,
          period: %{
            start_date: start_date,
            end_date: end_date
          }
        })
    end
  end

  # GET /api/reports/attendance
  def attendance(conn, params) do
    current_user = conn.assigns.current_user

    # Only managers and admins can generate attendance reports
    if current_user.role_id not in [2, 3] do
      conn
      |> put_status(:forbidden)
      |> json(%{error: "Access denied"})
    else
      {start_date, end_date} = get_date_range(params)
      team_id = Map.get(params, "team_id")
      format = Map.get(params, "format", "json")

      attendance_data = Reports.generate_attendance_report(team_id, start_date, end_date)

      case format do
        "csv" ->
          csv_content = Reports.attendance_to_csv(attendance_data)

          conn
          |> put_resp_content_type("text/csv")
          |> put_resp_header("content-disposition", "attachment; filename=\"attendance_#{start_date}_#{end_date}.csv\"")
          |> send_resp(200, csv_content)

        _ ->
          conn
          |> put_status(:ok)
          |> json(%{
            data: attendance_data,
            period: %{
              start_date: start_date,
              end_date: end_date
            }
          })
      end
    end
  end

  # GET /api/reports/payroll
  def payroll(conn, params) do
    current_user = conn.assigns.current_user

    # Only admins and HR can generate payroll reports
    if current_user.role_id != 3 do
      conn
      |> put_status(:forbidden)
      |> json(%{error: "Access denied"})
    else
      {start_date, end_date} = get_date_range(params)
      format = Map.get(params, "format", "json")

      payroll_data = Reports.generate_payroll_report(start_date, end_date)

      case format do
        "csv" ->
          csv_content = Reports.payroll_to_csv(payroll_data)

          conn
          |> put_resp_content_type("text/csv")
          |> put_resp_header("content-disposition", "attachment; filename=\"payroll_#{start_date}_#{end_date}.csv\"")
          |> send_resp(200, csv_content)

        _ ->
          conn
          |> put_status(:ok)
          |> json(%{
            data: payroll_data,
            period: %{
              start_date: start_date,
              end_date: end_date
            }
          })
      end
    end
  end

  # GET /api/reports/overtime
  def overtime(conn, params) do
    current_user = conn.assigns.current_user

    # Only managers and admins can generate overtime reports
    if current_user.role_id not in [2, 3] do
      conn
      |> put_status(:forbidden)
      |> json(%{error: "Access denied"})
    else
      {start_date, end_date} = get_date_range(params)
      team_id = Map.get(params, "team_id")
      format = Map.get(params, "format", "json")

      overtime_data = Reports.generate_overtime_report(team_id, start_date, end_date)

      case format do
        "csv" ->
          csv_content = Reports.overtime_to_csv(overtime_data)

          conn
          |> put_resp_content_type("text/csv")
          |> put_resp_header("content-disposition", "attachment; filename=\"overtime_#{start_date}_#{end_date}.csv\"")
          |> send_resp(200, csv_content)

        _ ->
          conn
          |> put_status(:ok)
          |> json(%{
            data: overtime_data,
            period: %{
              start_date: start_date,
              end_date: end_date
            }
          })
      end
    end
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
