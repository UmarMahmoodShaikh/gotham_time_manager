defmodule GothamWeb.SkillController do
  use GothamWeb, :controller

  alias Gotham.Activities
  alias Gotham.Activities.Skill

  action_fallback GothamWeb.FallbackController

  def index(conn, _params) do
    skills = Activities.list_skills()
    render(conn, :index, skills: skills)
  end

  def user_skills(conn, %{"userId" => user_id}) do
    user_id = normalize_id(user_id)
    skills = Activities.get_user_skills(user_id)
    render(conn, :index, skills: skills)
  end

  def create(conn, %{"skill" => skill_params}) do
    create_skill(conn, skill_params)
  end

  def create(conn, params) when is_map(params) do
    # Handle direct skill data without "skill" wrapper
    create_skill(conn, params)
  end

  def create(conn, _params) do
    conn
    |> put_status(:bad_request)
    |> json(%{
      errors: [
        %{
          status: "400",
          title: "Bad Request",
          detail: "Invalid request format. Expected skill data with 'label' field."
        }
      ]
    })
  end

  defp create_skill(conn, skill_params) do
    alias Gotham.Accounts.Role
    current_user = conn.assigns[:current_user]

    # Check if current user is admin, manager, or HR
    if current_user && current_user.role_id in [Role.admin_id(), Role.manager_id(), Role.hr_id()] do
      with {:ok, %Skill{} = skill} <- Activities.create_skill(skill_params) do
        conn
        |> put_status(:created)
        |> put_resp_header("location", ~p"/api/skills/#{skill}")
        |> render(:show, skill: skill)
      end
    else
      conn
      |> put_status(:forbidden)
      |> json(%{
        errors: [
          %{
            status: "403",
            title: "Forbidden",
            detail: "Only admins, managers, and HR can create skills"
          }
        ]
      })
    end
  end

  def show(conn, %{"id" => id}) do
    skill = Activities.get_skill!(id)
    render(conn, :show, skill: skill)
  end

  def update(conn, %{"id" => id, "skill" => skill_params}) do
    alias Gotham.Accounts.Role
    current_user = conn.assigns[:current_user]

    # Check if current user is admin, manager, or HR
    if current_user && current_user.role_id in [Role.admin_id(), Role.manager_id(), Role.hr_id()] do
      skill = Activities.get_skill!(id)

      with {:ok, %Skill{} = skill} <- Activities.update_skill(skill, skill_params) do
        render(conn, :show, skill: skill)
      end
    else
      conn
      |> put_status(:forbidden)
      |> json(%{
        errors: [
          %{
            status: "403",
            title: "Forbidden",
            detail: "Only admins, managers, and HR can update skills"
          }
        ]
      })
    end
  end

  def delete(conn, %{"id" => id}) do
    alias Gotham.Accounts.Role
    current_user = conn.assigns[:current_user]

    # Check if current user is admin, manager, or HR
    if current_user && current_user.role_id in [Role.admin_id(), Role.manager_id(), Role.hr_id()] do
      skill = Activities.get_skill!(id)

      with {:ok, %Skill{}} <- Activities.delete_skill(skill) do
        send_resp(conn, :no_content, "")
      end
    else
      conn
      |> put_status(:forbidden)
      |> json(%{
        errors: [
          %{
            status: "403",
            title: "Forbidden",
            detail: "Only admins, managers, and HR can delete skills"
          }
        ]
      })
    end
  end

  defp normalize_id(id) when is_integer(id), do: id

  defp normalize_id(id) when is_binary(id) do
    case Integer.parse(id) do
      {int, _} -> int
      :error -> id
    end
  end
end
