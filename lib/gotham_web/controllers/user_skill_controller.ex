defmodule GothamWeb.UserSkillController do
  use GothamWeb, :controller

  alias Gotham.Activities
  alias Gotham.Activities.UserSkill

  action_fallback GothamWeb.FallbackController

  # Router exposes extra endpoints:
  #   post "/users/:userid/skills/:skillid", UserSkillController, :create
  #   delete "/users/:userid/skills/:skillid", UserSkillController, :delete
  # Also has resources "/user_skills" for standard CRUD, but keep only those used.

  def create(conn, %{"userid" => user_id, "skillid" => skill_id}) do
    alias Gotham.Accounts.Role
    current_user = conn.assigns[:current_user]

    # Check if current user is admin or manager
    if current_user && current_user.role_id in [Role.admin_id(), Role.manager_id()] do
      # Verify that both user and skill exist
      with {:ok, _user} <- verify_user_exists(user_id),
           {:ok, _skill} <- verify_skill_exists(skill_id),
           {:ok, user_skill} <-
             Activities.create_user_skill(%{user_id: user_id, skill_id: skill_id}) do
        conn
        |> put_status(:created)
        |> put_resp_header("location", ~p"/api/user_skills/#{user_skill}")
        |> render(:show, user_skill: user_skill)
      else
        {:error, :not_found} ->
          conn
          |> put_status(:not_found)
          |> json(%{errors: [%{status: "404", title: "User or Skill not found"}]})

        {:error, changeset} ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{
            errors: [%{status: "422", title: "Validation failed", detail: changeset.errors}]
          })
      end
    else
      conn
      |> put_status(:forbidden)
      |> json(%{
        errors: [
          %{
            status: "403",
            title: "Forbidden",
            detail: "Only admins and managers can assign skills"
          }
        ]
      })
    end
  end

  def create(conn, %{"user_skill" => user_skill_params}) do
    with {:ok, %UserSkill{} = user_skill} <- Activities.create_user_skill(user_skill_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/user_skills/#{user_skill}")
      |> render(:show, user_skill: user_skill)
    end
  end

  def delete(conn, %{"userid" => _userid, "skillid" => _skillid}) do
    conn
    |> send_resp(:not_implemented, "")
  end

  def delete(conn, %{"id" => id}) do
    user_skill = Activities.get_user_skill!(id)

    with {:ok, %UserSkill{}} <- Activities.delete_user_skill(user_skill) do
      send_resp(conn, :no_content, "")
    end
  end

  # Standard REST for /user_skills
  def index(conn, _params) do
    user_skills = Activities.list_user_skills()
    render(conn, :index, user_skills: user_skills)
  end

  def show(conn, %{"id" => id}) do
    user_skill = Activities.get_user_skill!(id)
    render(conn, :show, user_skill: user_skill)
  end

  def update(conn, %{"id" => id, "user_skill" => user_skill_params}) do
    user_skill = Activities.get_user_skill!(id)

    with {:ok, %UserSkill{} = user_skill} <-
           Activities.update_user_skill(user_skill, user_skill_params) do
      render(conn, :show, user_skill: user_skill)
    end
  end

  # Helper functions
  defp verify_user_exists(user_id) do
    Gotham.Accounts.get_user(user_id)
  end

  defp verify_skill_exists(skill_id) do
    Activities.get_skill(skill_id)
  end
end
