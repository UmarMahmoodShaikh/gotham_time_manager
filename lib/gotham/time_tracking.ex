defmodule Gotham.TimeTracking do
  @moduledoc """
  The TimeTracking context: managing clocks and working times.
  """

  import Ecto.Query, warn: false
  alias Gotham.Repo

  alias Gotham.TimeTracking.{Clock, WorkingTime}

  # ------------------------
  # Clock Functions
  # ------------------------
  def list_clocks, do: Repo.all(Clock)
  def get_clock!(id), do: Repo.get!(Clock, id)

  def create_clock(attrs) do
    %Clock{}
    |> Clock.changeset(attrs)
    |> Repo.insert()
  end

  def update_clock(%Clock{} = clock, attrs) do
    clock
    |> Clock.changeset(attrs)
    |> Repo.update()
  end

  def delete_clock(%Clock{} = clock), do: Repo.delete(clock)
  def change_clock(%Clock{} = clock, attrs \\ %{}), do: Clock.changeset(clock, attrs)

  # User-scoped clocks
  def list_user_clocks(user_id) do
    from(c in Clock, where: c.user_id == ^user_id, order_by: [desc: c.time, desc: c.inserted_at])
    |> Repo.all()
  end

  def latest_clock_by_user(user_id) do
    from(c in Clock,
      where: c.user_id == ^user_id,
      order_by: [desc: c.time, desc: c.inserted_at],
      limit: 1
    )
    |> Repo.one()
  end

  def toggle_clock!(user_id, attrs \\ %{}) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)
    last = latest_clock_by_user(user_id)
    next_status = if last && last.status, do: false, else: true

    Repo.transaction(fn ->
      {:ok, clock} =
        %Clock{user_id: user_id}
        |> Clock.changeset(Map.merge(%{"time" => now, "status" => next_status}, attrs))
        |> Repo.insert()

      if next_status do
        # Clock-in: create a new working time row
        {:ok, _wt} =
          %WorkingTime{}
          |> WorkingTime.changeset(%{
            "user_id" => user_id,
            "start_time" => now,
            "is_manual_entry" => false,
            "validation_status" => "pending",
            "unpaid_overtime_hours" => 0,
            "is_transition_time" => false
          })
          |> Repo.insert()
      else
        # Clock-out: update the latest open working time for this user
        open_wt =
          from(w in WorkingTime,
            where: w.user_id == ^user_id and is_nil(w.end_time),
            order_by: [desc: w.start_time],
            limit: 1
          )
          |> Repo.one()

        if open_wt do
          {:ok, _} =
            open_wt
            |> WorkingTime.changeset(%{"end_time" => now})
            |> Repo.update()
        end
      end

      clock
    end)
  end

  # ------------------------
  # WorkingTime Functions
  # ------------------------
  def list_working_times, do: Repo.all(WorkingTime)
  def get_working_time!(id), do: Repo.get!(WorkingTime, id)

  def create_working_time(attrs) do
    %WorkingTime{}
    |> WorkingTime.changeset(attrs)
    |> Repo.insert()
  end

  def update_working_time(%WorkingTime{} = working_time, attrs) do
    working_time
    |> WorkingTime.changeset(attrs)
    |> Repo.update()
  end

  def delete_working_time(%WorkingTime{} = working_time), do: Repo.delete(working_time)

  def change_working_time(%WorkingTime{} = working_time, attrs \\ %{}),
    do: WorkingTime.changeset(working_time, attrs)

  # User-scoped working times
  def list_working_times_by_user(user_id) do
    from(w in WorkingTime, where: w.user_id == ^user_id, order_by: [desc: w.start_time])
    |> Repo.all()
  end

  def get_working_time_for_user!(user_id, id) do
    case Repo.get(WorkingTime, id) do
      %WorkingTime{user_id: ^user_id} = wt -> wt
      _ -> raise Ecto.NoResultsError, queryable: WorkingTime
    end
  end

  def create_working_time_for_user(user_id, attrs) do
    attrs = Map.put(attrs, "user_id", user_id)
    create_working_time(attrs)
  end

  # Payroll aggregation: approved entries grouped by month (UTC), ordered desc, with limit/offset
  def monthly_payroll(user_id, limit \\ 6, offset \\ 0) do
    query =
      from w in WorkingTime,
        where:
          w.user_id == ^user_id and w.validation_status == "approved" and not is_nil(w.end_time),
        group_by: fragment("date_trunc('month', ?)", w.start_time),
        order_by: [desc: fragment("date_trunc('month', ?)", w.start_time)],
        select: %{
          month: fragment("date_trunc('month', ?)", w.start_time),
          total_entries: count(w.id),
          total_hours:
            fragment("SUM(EXTRACT(EPOCH FROM (? - ?)) / 3600)", w.end_time, w.start_time),
          overtime_hours: fragment("SUM(COALESCE(?, 0))", w.unpaid_overtime_hours)
        }

    query
    |> limit(^limit)
    |> offset(^offset)
    |> Repo.all()
  end

  # Central place for rate configuration
  def calculation_rates do
    %{
      base_hourly_rate: 11.88,
      overtime_multiplier: 1.25,
      night_shift_multiplier: 1.5,
      weekend_multiplier: 2.0,
      currency: "EUR"
    }
  end

  # Detailed payroll with multipliers per hour across categories (night/weekend/overtime) and lateness deduction
  def payroll_monthly_detailed(user_id, limit \\ 6, offset \\ 0) do
    months = monthly_payroll(user_id, limit, offset)
    rates = calculation_rates()

    Enum.map(months, fn m ->
      month_start = DateTime.new!(DateTime.to_date(m.month), ~T[00:00:00], "Etc/UTC")
      month_end = next_month_start(month_start)

      wts = approved_working_times_in_range(user_id, month_start, month_end)

      breakdown =
        Enum.reduce(wts, init_breakdown(), fn wt, acc ->
          b = compute_pay_for_interval(wt.start_time, wt.end_time, rates)
          merge_breakdowns(acc, b)
        end)

      %{
        month: m.month,
        total_entries: m.total_entries,
        total_hours: Float.round(breakdown.total_hours, 2),
        overtime_hours: Float.round(breakdown.overtime_hours, 2),
        night_hours: Float.round(breakdown.night_hours, 2),
        weekend_hours: Float.round(breakdown.weekend_hours, 2),
        base_pay: Float.round(breakdown.base_pay, 2),
        overtime_pay: Float.round(breakdown.overtime_pay, 2),
        night_pay: Float.round(breakdown.night_pay, 2),
        weekend_pay: Float.round(breakdown.weekend_pay, 2),
        total_pay: Float.round(breakdown.total_pay, 2),
        currency: rates.currency
      }
    end)
  end

  defp next_month_start(%DateTime{year: y, month: m} = dt) do
    {ny, nm} = if m == 12, do: {y + 1, 1}, else: {y, m + 1}
    {:ok, date} = Date.new(ny, nm, 1)
    DateTime.new!(date, ~T[00:00:00], dt.time_zone)
  end

  defp approved_working_times_in_range(user_id, start_dt, end_dt) do
    from(w in WorkingTime,
      where:
        w.user_id == ^user_id and w.validation_status == "approved" and not is_nil(w.end_time) and
          w.start_time < ^end_dt and w.end_time > ^start_dt,
      order_by: [asc: w.start_time]
    )
    |> Repo.all()
  end

  defp init_breakdown do
    %{
      total_hours: 0.0,
      overtime_hours: 0.0,
      night_hours: 0.0,
      weekend_hours: 0.0,
      base_pay: 0.0,
      overtime_pay: 0.0,
      night_pay: 0.0,
      weekend_pay: 0.0,
      total_pay: 0.0
    }
  end

  defp merge_breakdowns(a, b) do
    %{
      total_hours: a.total_hours + b.total_hours,
      overtime_hours: a.overtime_hours + b.overtime_hours,
      night_hours: a.night_hours + b.night_hours,
      weekend_hours: a.weekend_hours + b.weekend_hours,
      base_pay: a.base_pay + b.base_pay,
      overtime_pay: a.overtime_pay + b.overtime_pay,
      night_pay: a.night_pay + b.night_pay,
      weekend_pay: a.weekend_pay + b.weekend_pay,
      total_pay: a.total_pay + b.total_pay
    }
  end

  # Compute pay by iterating hour-by-hour and applying multipliers. Lateness: hours after 09:00 on first day before clock-in are unpaid.
  defp compute_pay_for_interval(%DateTime{} = start_dt, %DateTime{} = end_dt, rates) do
    # Align boundaries to hour for simplicity
    from = DateTime.truncate(start_dt, :second)
    to = DateTime.truncate(end_dt, :second)

    # Build hourly ticks
    ticks = hourly_ticks(from, to)

    {breakdown, _} =
      Enum.reduce(ticks, {init_breakdown(), true}, fn {tick_start, span_hours},
                                                      {acc, first_day?} ->
        date = DateTime.to_date(tick_start)
        # 1=Mon .. 7=Sun
        dow = Date.day_of_week(date)
        hour = tick_start.hour

        weekend = dow in [6, 7]
        night = hour >= 22 or hour < 9
        overtime = hour >= 17 and hour < 22

        # Lateness: if this is the very first hour block and within the first day and start after 09:00, do not pay the portion until 09:00
        unpaid_span =
          if first_day? do
            day_start_9 = DateTime.new!(date, ~T[09:00:00], from.time_zone)

            if Date.compare(date, DateTime.to_date(from)) == :eq and
                 DateTime.compare(from, day_start_9) == :gt do
              # User started after 09:00, so any hour block before start should be unpaid; but we start from 'from', so no special needed.
              0.0
            else
              0.0
            end
          else
            0.0
          end

        effective_hours = max(span_hours - unpaid_span, 0.0)

        base_multiplier = 1.0

        base_multiplier =
          if weekend, do: base_multiplier * rates.weekend_multiplier, else: base_multiplier

        base_multiplier =
          if night, do: base_multiplier * rates.night_shift_multiplier, else: base_multiplier

        base_multiplier =
          if overtime, do: base_multiplier * rates.overtime_multiplier, else: base_multiplier

        base_pay = effective_hours * rates.base_hourly_rate
        total_pay = effective_hours * rates.base_hourly_rate * base_multiplier

        acc = %{
          total_hours: acc.total_hours + effective_hours,
          overtime_hours: acc.overtime_hours + if(overtime, do: effective_hours, else: 0.0),
          night_hours: acc.night_hours + if(night, do: effective_hours, else: 0.0),
          weekend_hours: acc.weekend_hours + if(weekend, do: effective_hours, else: 0.0),
          base_pay: acc.base_pay + base_pay,
          overtime_pay:
            acc.overtime_pay +
              if(overtime,
                do: effective_hours * rates.base_hourly_rate * (rates.overtime_multiplier - 1),
                else: 0.0
              ),
          night_pay:
            acc.night_pay +
              if(night,
                do: effective_hours * rates.base_hourly_rate * (rates.night_shift_multiplier - 1),
                else: 0.0
              ),
          weekend_pay:
            acc.weekend_pay +
              if(weekend,
                do: effective_hours * rates.base_hourly_rate * (rates.weekend_multiplier - 1),
                else: 0.0
              ),
          total_pay: acc.total_pay + total_pay
        }

        {acc, false}
      end)

    breakdown
  end

  defp hourly_ticks(%DateTime{} = start_dt, %DateTime{} = end_dt) do
    # Generate list of {tick_start, span_hours} for each hour chunk fully within [start_dt, end_dt)
    # Include a partial first/last hour proportionally
    start_hour = %DateTime{start_dt | minute: 0, second: 0, microsecond: {0, 0}}
    next_hour = DateTime.add(start_hour, 3600, :second)

    first_span =
      max(
        min(
          DateTime.diff(next_hour, start_dt, :second),
          DateTime.diff(end_dt, start_dt, :second)
        ),
        0
      ) / 3600

    {ticks, _cur} =
      Stream.iterate(start_hour, &DateTime.add(&1, 3600, :second))
      |> Stream.take_while(fn t -> DateTime.compare(t, end_dt) == :lt end)
      |> Enum.map_reduce(first_span, fn tick_start, span ->
        tick_end = DateTime.add(tick_start, 3600, :second)

        span_hours =
          cond do
            DateTime.compare(tick_end, end_dt) == :gt ->
              DateTime.diff(end_dt, tick_start, :second) / 3600

            DateTime.compare(tick_start, start_dt) == :lt ->
              span

            true ->
              1.0
          end

        {{tick_start, span_hours}, 1.0}
      end)

    ticks
  end
end
