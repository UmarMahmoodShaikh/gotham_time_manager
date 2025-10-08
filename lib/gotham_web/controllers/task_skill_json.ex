defmodule GothamWeb.TaskSkillJSON do
  alias Gotham.Activities.TaskSkill

  @doc """
  Renders a list of task_skills.
  """
  def index(%{task_skills: task_skills}) do
    %{data: for(task_skill <- task_skills, do: data(task_skill))}
  end

  @doc """
  Renders a single task_skill.
  """
  def show(%{task_skill: task_skill}) do
    %{data: data(task_skill)}
  end

  defp data(%TaskSkill{} = task_skill) do
    %{
      id: task_skill.id
    }
  end
end
