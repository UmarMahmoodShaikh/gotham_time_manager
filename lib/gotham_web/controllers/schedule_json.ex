defmodule GothamWeb.ScheduleJSON do
  alias Gotham.Scheduling.Schedule

  @doc """
  Renders a list of schedules.
  """
  def index(%{schedules: schedules}) do
    %{data: for(schedule <- schedules, do: data(schedule))}
  end

  @doc """
  Renders a single schedule.
  """
  def show(%{schedule: schedule}) do
    %{data: data(schedule)}
  end

  defp data(%Schedule{} = schedule) do
    %{
      id: schedule.id,
      start_date: schedule.start_date,
      end_date: schedule.end_date,
      consecutive_night_count: schedule.consecutive_night_count
    }
  end
end
