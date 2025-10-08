defmodule Gotham.TimeTrackingFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Gotham.TimeTracking` context.
  """

  def clock_fixture(attrs \\ %{}) do
    {:ok, clock} =
      attrs
      |> Enum.into(%{
        geolocation_data: %{},
        status: true,
        time: ~U[2025-10-06 08:49:00Z]
      })
      |> Gotham.TimeTracking.create_clock()

    clock
  end

  @doc """
  Generate a working_time.
  """
  def working_time_fixture(attrs \\ %{}) do
    {:ok, working_time} =
      attrs
      |> Enum.into(%{
        end_time: ~U[2025-10-06 08:49:00Z],
        is_manual_entry: true,
        is_transition_time: true,
        start_time: ~U[2025-10-06 08:49:00Z],
        unpaid_overtime_hours: "120.5",
        validation_status: "some validation_status"
      })
      |> Gotham.TimeTracking.create_working_time()

    working_time
  end
end
