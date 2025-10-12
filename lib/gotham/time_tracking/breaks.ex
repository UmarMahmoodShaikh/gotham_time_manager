defmodule Gotham.TimeTracking.Breaks do
  @moduledoc """
  Context for managing break time tracking
  """

  import Ecto.Query, warn: false
  alias Gotham.Repo
  alias Gotham.TimeTracking.Break

  @doc """
  Start a break for a user
  """
  def start_break(user_id, break_type \\ "regular") do
    # Check if user has an active break
    case get_active_break(user_id) do
      nil ->
        # Check if user is clocked in
        case Gotham.TimeTracking.get_active_entry(user_id) do
          nil ->
            {:error, :not_clocked_in}

          _time_entry ->
            %Break{}
            |> Break.changeset(%{
              user_id: user_id,
              break_type: break_type,
              start_time: DateTime.utc_now(),
              status: "active"
            })
            |> Repo.insert()
        end

      _active_break ->
        {:error, :already_on_break}
    end
  end

  @doc """
  End the current active break for a user
  """
  def end_break(user_id) do
    case get_active_break(user_id) do
      nil ->
        {:error, :no_active_break}

      break_entry ->
        end_time = DateTime.utc_now()
        duration_minutes = DateTime.diff(end_time, break_entry.start_time, :second) |> div(60)

        break_entry
        |> Break.changeset(%{
          end_time: end_time,
          duration_minutes: duration_minutes,
          status: "completed"
        })
        |> Repo.update()
    end
  end

  @doc """
  Get the active break for a user
  """
  def get_active_break(user_id) do
    from(b in Break,
      where: b.user_id == ^user_id and b.status == "active",
      order_by: [desc: b.start_time],
      limit: 1
    )
    |> Repo.one()
  end

  @doc """
  List break history for a user with filters
  """
  def list_break_history(filters) do
    user_id = Map.get(filters, :user_id)
    page = Map.get(filters, :page, 1)
    limit = Map.get(filters, :limit, 20)
    start_date = Map.get(filters, :start_date)
    end_date = Map.get(filters, :end_date)

    query = from(b in Break,
      where: b.user_id == ^user_id,
      order_by: [desc: b.start_time]
    )

    query = if start_date do
      from(b in query, where: b.start_time >= ^start_date)
    else
      query
    end

    query = if end_date do
      from(b in query, where: b.start_time <= ^end_date)
    else
      query
    end

    offset = (page - 1) * limit

    breaks = query
    |> limit(^limit)
    |> offset(^offset)
    |> Repo.all()

    total_count = from(b in query, select: count(b.id)) |> Repo.one()

    meta = %{
      current_page: page,
      per_page: limit,
      total_count: total_count,
      total_pages: ceil(total_count / limit)
    }

    {breaks, meta}
  end

  @doc """
  Get daily break summary for a user
  """
  def get_daily_break_summary(user_id, date) do
    start_of_day = DateTime.new!(date, ~T[00:00:00], "Etc/UTC")
    end_of_day = DateTime.new!(date, ~T[23:59:59], "Etc/UTC")

    breaks = from(b in Break,
      where: b.user_id == ^user_id
        and b.start_time >= ^start_of_day
        and b.start_time <= ^end_of_day
        and b.status == "completed",
      select: %{
        break_type: b.break_type,
        duration_minutes: b.duration_minutes
      }
    )
    |> Repo.all()

    total_minutes = breaks |> Enum.reduce(0, fn break, acc ->
      acc + (break.duration_minutes || 0)
    end)

    break_counts = breaks
    |> Enum.group_by(& &1.break_type)
    |> Enum.map(fn {type, type_breaks} ->
      {type, %{
        count: length(type_breaks),
        total_minutes: Enum.reduce(type_breaks, 0, fn b, acc ->
          acc + (b.duration_minutes || 0)
        end)
      }}
    end)
    |> Map.new()

    %{
      date: date,
      total_break_minutes: total_minutes,
      total_breaks: length(breaks),
      break_breakdown: break_counts
    }
  end
end
