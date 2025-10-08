defmodule GothamWeb.WorkingTimeJSON do
  alias Gotham.TimeTracking.WorkingTime

  @doc """
  Renders a list of working_times.
  """
  def index(%{working_times: working_times}) do
    %{data: for(working_time <- working_times, do: data(working_time))}
  end

  @doc """
  Renders a single working_time.
  """
  def show(%{working_time: working_time}) do
    %{data: data(working_time)}
  end

  defp data(%WorkingTime{} = working_time) do
    %{
      user_id: working_time.user_id,
      start_time: working_time.start_time,
      end_time: working_time.end_time,
      is_manual_entry: working_time.is_manual_entry,
      validation_status: working_time.validation_status,
      unpaid_overtime_hours: working_time.unpaid_overtime_hours,
      is_transition_time: working_time.is_transition_time
    }
  end
end
