defmodule Gotham.SchedulingFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Gotham.Scheduling` context.
  """

  @doc """
  Generate a shift.
  """
  def shift_fixture(attrs \\ %{}) do
    {:ok, shift} =
      attrs
      |> Enum.into(%{
        is_constraint_hour: true,
        is_night_shift: true,
        name: "some name"
      })
      |> Gotham.Scheduling.create_shift()

    shift
  end

  @doc """
  Generate a schedule.
  """
  def schedule_fixture(attrs \\ %{}) do
    {:ok, schedule} =
      attrs
      |> Enum.into(%{
        consecutive_night_count: 42,
        end_date: ~D[2025-10-06],
        start_date: ~D[2025-10-06]
      })
      |> Gotham.Scheduling.create_schedule()

    schedule
  end

  @doc """
  Generate a leave.
  """
  def leave_fixture(attrs \\ %{}) do
    {:ok, leave} =
      attrs
      |> Enum.into(%{
        end_date: ~D[2025-10-06],
        leave_type: "some leave_type",
        start_date: ~D[2025-10-06],
        status: "some status"
      })
      |> Gotham.Scheduling.create_leave()

    leave
  end
end
