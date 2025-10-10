defmodule GothamWeb.ShiftJSON do
  alias Gotham.Scheduling.Shift

  @doc """
  Renders a list of shifts.
  """
  def index(%{shifts: shifts}) do
    %{data: for(shift <- shifts, do: data(shift))}
  end

  @doc """
  Renders a single shift.
  """
  def show(%{shift: shift}) do
    %{data: data(shift)}
  end

  defp data(%Shift{} = shift) do
    %{
      name: shift.name,
      is_night_shift: shift.is_night_shift,
      is_constraint_hour: shift.is_constraint_hour,
      start_time: shift.start_time,
      end_time: shift.end_time
    }
  end
end
