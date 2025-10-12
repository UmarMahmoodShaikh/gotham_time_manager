defmodule Gotham.Payroll do
  @moduledoc """
  The Payroll context.
  """

  import Ecto.Query, warn: false
  alias Gotham.Repo
  alias Gotham.Payroll.CompensationLog
  alias Gotham.TimeTracking.TimeEntry

  @doc """
  Returns the list of compensation logs.
  """
  def list_compensation_logs do
    Repo.all(CompensationLog)
  end

  @doc """
  Gets a single compensation log by ID.

  Raises `Ecto.NoResultsError` if the log does not exist.
  """
  def get_compensation_log!(id), do: Repo.get!(CompensationLog, id)

  @doc """
  Creates a compensation log.
  """
  def create_compensation_log(attrs \\ %{}) do
    %CompensationLog{}
    |> CompensationLog.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a compensation log.
  """
  def update_compensation_log(%CompensationLog{} = compensation_log, attrs) do
    compensation_log
    |> CompensationLog.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a compensation log.
  """
  def delete_compensation_log(%CompensationLog{} = compensation_log) do
    Repo.delete(compensation_log)
  end

  @doc """
  Returns a changeset for tracking compensation log changes.
  """
  def change_compensation_log(%CompensationLog{} = compensation_log, attrs \\ %{}) do
    CompensationLog.changeset(compensation_log, attrs)
  end

  @doc """
  Get payroll summary for a user in a date range.
  """
  def get_payroll_summary(user_id, start_date, end_date) do
    query = from(t in TimeEntry,
      where: t.user_id == ^user_id and
             t.status == "approved" and
             t.clock_in >= ^DateTime.new!(start_date, ~T[00:00:00], "Etc/UTC") and
             t.clock_in <= ^DateTime.new!(end_date, ~T[23:59:59], "Etc/UTC"),
      select: %{
        total_hours: sum(t.total_hours),
        total_entries: count(t.id)
      }
    )

    result = Repo.one(query) || %{total_hours: Decimal.new(0), total_entries: 0}

    total_hours = result.total_hours || Decimal.new(0)
    regular_hours = if Decimal.gt?(total_hours, 160), do: Decimal.new(160), else: total_hours
    overtime_hours = if Decimal.gt?(total_hours, 160), do: Decimal.sub(total_hours, 160), else: Decimal.new(0)

    # Default pay rates
    regular_rate = Decimal.new(25) # $25/hour
    overtime_rate = Decimal.new("37.5") # $37.5/hour

    regular_pay = Decimal.mult(regular_hours, regular_rate)
    overtime_pay = Decimal.mult(overtime_hours, overtime_rate)
    gross_pay = Decimal.add(regular_pay, overtime_pay)

    # Simple tax calculation (30%)
    taxes = Decimal.mult(gross_pay, Decimal.new("0.3"))
    net_pay = Decimal.sub(gross_pay, taxes)

    %{
      total_hours: Decimal.to_float(total_hours),
      regular_hours: Decimal.to_float(regular_hours),
      overtime_hours: Decimal.to_float(overtime_hours),
      regular_rate: Decimal.to_float(regular_rate),
      overtime_rate: Decimal.to_float(overtime_rate),
      regular_pay: Decimal.to_float(regular_pay),
      overtime_pay: Decimal.to_float(overtime_pay),
      gross_pay: Decimal.to_float(gross_pay),
      taxes: Decimal.to_float(taxes),
      net_pay: Decimal.to_float(net_pay),
      total_entries: result.total_entries
    }
  end

  @doc """
  Get payroll history for a user with pagination.
  """
  def get_payroll_history(user_id, page, limit) do
    months = get_past_months(12)
    offset = (page - 1) * limit

    payroll_records = months
    |> Enum.slice(offset, limit)
    |> Enum.map(fn {start_date, end_date} ->
      summary = get_payroll_summary(user_id, start_date, end_date)

      Map.merge(summary, %{
        period_start: start_date,
        period_end: end_date,
        period_label: "#{Date.to_string(start_date)} - #{Date.to_string(end_date)}"
      })
    end)

    meta = %{
      current_page: page,
      per_page: limit,
      total_count: length(months),
      total_pages: ceil(length(months) / limit)
    }

    {payroll_records, meta}
  end

  @doc """
  Generate payroll for all users in a date range.
  """
  def generate_payroll(start_date, end_date) do
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
        total_hours: sum(t.total_hours)
      }
    )

    user_summaries = Repo.all(query)

    payroll_data = Enum.map(user_summaries, fn user_summary ->
      summary = get_payroll_summary(user_summary.user_id, start_date, end_date)
      Map.merge(user_summary, summary)
    end)

    total_gross_pay = payroll_data |> Enum.map(& &1.gross_pay) |> Enum.sum()
    total_net_pay = payroll_data |> Enum.map(& &1.net_pay) |> Enum.sum()
    total_taxes = payroll_data |> Enum.map(& &1.taxes) |> Enum.sum()

    {:ok, %{
      employees: payroll_data,
      summary: %{
        total_employees: length(payroll_data),
        total_gross_pay: total_gross_pay,
        total_net_pay: total_net_pay,
        total_taxes: total_taxes,
        period_start: start_date,
        period_end: end_date
      }
    }}
  end

  @doc """
  Get pay rates for all users.
  """
  def get_pay_rates() do
    [
      %{user_id: nil, role: "employee", regular_rate: 25.00, overtime_rate: 37.50, currency: "USD"},
      %{user_id: nil, role: "manager", regular_rate: 35.00, overtime_rate: 52.50, currency: "USD"},
      %{user_id: nil, role: "admin", regular_rate: 45.00, overtime_rate: 67.50, currency: "USD"}
    ]
  end

  @doc """
  Update pay rates for a user.
  """
  def update_pay_rates(_user_id, params) do
    {:ok, params}
  end

  defp get_past_months(count) do
    today = Date.utc_today()

    0..(count - 1)
    |> Enum.map(fn months_ago ->
      month_date = Date.add(today, -months_ago * 30)
      start_date = Date.beginning_of_month(month_date)
      end_date = Date.end_of_month(month_date)
      {start_date, end_date}
    end)
    |> Enum.reverse()
  end
end
