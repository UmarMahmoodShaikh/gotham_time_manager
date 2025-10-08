defmodule GothamWeb.UserSkillJSON do
  alias Gotham.Activities.UserSkill

  @doc """
  Renders a list of user_skills.
  """
  def index(%{user_skills: user_skills}) do
    %{data: for(user_skill <- user_skills, do: data(user_skill))}
  end

  @doc """
  Renders a single user_skill.
  """
  def show(%{user_skill: user_skill}) do
    %{data: data(user_skill)}
  end

  defp data(%UserSkill{} = user_skill) do
    %{
      id: user_skill.id
    }
  end
end
