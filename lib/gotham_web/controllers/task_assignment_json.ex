defmodule GothamWeb.TaskAssignmentJSON do
  alias Gotham.Activities.TaskAssignment

  @doc """
  Renders a list of task_assignments.
  """
  def index(%{task_assignments: task_assignments}) do
    %{data: for(task_assignment <- task_assignments, do: data(task_assignment))}
  end

  @doc """
  Renders a single task_assignment.
  """
  def show(%{task_assignment: task_assignment}) do
    %{data: data(task_assignment)}
  end

  defp data(%TaskAssignment{} = task_assignment) do
    %{
      id: task_assignment.id
    }
  end
end
