defmodule GothamWeb.LeaveJSON do
  alias Gotham.Scheduling.Leave

  @doc """
  Renders a list of leaves.
  """
  def index(%{leaves: leaves}) do
    %{data: for(leave <- leaves, do: data(leave))}
  end

  @doc """
  Renders a single leave.
  """
  def show(%{leave: leave}) do
    %{data: data(leave)}
  end

  defp data(%Leave{} = leave) do
    %{
      id: leave.id,
      leave_type: leave.leave_type,
      start_date: leave.start_date,
      end_date: leave.end_date,
      status: leave.status
    }
  end
end
