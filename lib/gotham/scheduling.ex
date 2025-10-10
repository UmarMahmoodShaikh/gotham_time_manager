defmodule Gotham.Scheduling do
  @moduledoc """
  The Scheduling context: managing shifts, schedules, and leaves.
  """

  import Ecto.Query, warn: false
  alias Gotham.Repo

  alias Gotham.Scheduling.{Shift, Schedule, Leave}

  # ------------------------
  # Shift Functions
  # ------------------------
  def list_shifts, do: Repo.all(Shift)
  def get_shift!(id), do: Repo.get!(Shift, id)

  def create_shift(attrs) do
    %Shift{}
    |> Shift.changeset(attrs)
    |> Repo.insert()
  end

  def update_shift(%Shift{} = shift, attrs) do
    shift
    |> Shift.changeset(attrs)
    |> Repo.update()
  end

  def delete_shift(%Shift{} = shift), do: Repo.delete(shift)
  def change_shift(%Shift{} = shift, attrs \\ %{}), do: Shift.changeset(shift, attrs)

  # ------------------------
  # Schedule Functions
  # ------------------------
  def list_schedules, do: Repo.all(Schedule)
  def get_schedule!(id), do: Repo.get!(Schedule, id)

  def create_schedule(attrs) do
    %Schedule{}
    |> Schedule.changeset(attrs)
    |> Repo.insert()
  end

  def update_schedule(%Schedule{} = schedule, attrs) do
    schedule
    |> Schedule.changeset(attrs)
    |> Repo.update()
  end

  def delete_schedule(%Schedule{} = schedule), do: Repo.delete(schedule)

  def change_schedule(%Schedule{} = schedule, attrs \\ %{}),
    do: Schedule.changeset(schedule, attrs)

  # Constraints for an employee: return periods where shifts are constraint hours or leaves overlap
  def constraints_for_employee(employee_id) do
    query =
      from s in Schedule,
           where: s.user_id == ^employee_id,
           join: sh in assoc(s, :shift),
           where: sh.is_constraint_hour == true,
           select: %{
             schedule_id: s.id,
             start_date: s.date,
             shift_name: sh.name,
             start_time: sh.start_time,
             end_time: sh.end_time
           }

    Repo.all(query)
  end

  # Create schedules in batch
  def create_schedules_batch(schedules_attrs) when is_list(schedules_attrs) do
    Repo.transaction(fn ->
      Enum.map(schedules_attrs, fn attrs ->
        case create_schedule(attrs) do
          {:ok, schedule} -> schedule
          {:error, changeset} -> Repo.rollback(changeset)
        end
      end)
    end)
  end

  # Night shift alert: list users who have a night shift today
  def night_shift_alert() do
    today = Date.utc_today()

    query =
      from s in Schedule,
        where: s.start_date <= ^today and s.end_date >= ^today,
        join: sh in assoc(s, :shift),
        where: sh.is_night_shift == true,
        select: %{schedule_id: s.id, user_id: s.user_id, shift_id: s.shift_id}

    Repo.all(query)
  end

  # ------------------------
  # Leave Functions
  # ------------------------
  def list_leaves, do: Repo.all(Leave)
  def get_leave!(id), do: Repo.get!(Leave, id)

  def create_leave(attrs) do
    %Leave{}
    |> Leave.changeset(attrs)
    |> Repo.insert()
  end

  def update_leave(%Leave{} = leave, attrs) do
    leave
    |> Leave.changeset(attrs)
    |> Repo.update()
  end

  def delete_leave(%Leave{} = leave), do: Repo.delete(leave)
  def change_leave(%Leave{} = leave, attrs \\ %{}), do: Leave.changeset(leave, attrs)
end
