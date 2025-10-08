defmodule GothamWeb.TaskSkillController do
  use GothamWeb, :controller

  alias Gotham.Activities
  alias Gotham.Activities.TaskSkill

  action_fallback GothamWeb.FallbackController

  # Router exposes additional endpoint:
  #   put "/tasks/:taskid/skills/:skillid", TaskSkillController, :update
  # Implement param-based update signature and return 501 if context is missing.

  def update(conn, %{"taskid" => _taskid, "skillid" => _skillid}) do
    conn
    |> put_status(:not_implemented)
    |> json(%{errors: [%{status: "501", title: "Not Implemented"}]})
  end

  def update(conn, %{"id" => id, "task_skill" => task_skill_params}) do
    task_skill = Activities.get_task_skill!(id)

    with {:ok, %TaskSkill{} = task_skill} <-
           Activities.update_task_skill(task_skill, task_skill_params) do
      render(conn, :show, task_skill: task_skill)
    end
  end

  # Standard REST for /task_skills
  def index(conn, _params) do
    task_skills = Activities.list_task_skills()
    render(conn, :index, task_skills: task_skills)
  end

  def create(conn, %{"task_skill" => task_skill_params}) do
    with {:ok, %TaskSkill{} = task_skill} <- Activities.create_task_skill(task_skill_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/task_skills/#{task_skill}")
      |> render(:show, task_skill: task_skill)
    end
  end

  def show(conn, %{"id" => id}) do
    task_skill = Activities.get_task_skill!(id)
    render(conn, :show, task_skill: task_skill)
  end

  def delete(conn, %{"id" => id}) do
    task_skill = Activities.get_task_skill!(id)

    with {:ok, %TaskSkill{}} <- Activities.delete_task_skill(task_skill) do
      send_resp(conn, :no_content, "")
    end
  end
end
