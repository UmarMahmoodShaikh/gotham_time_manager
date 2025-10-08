defmodule GothamWeb.TeamController do
  use GothamWeb, :controller

  alias Gotham.Organizations
  alias Gotham.Organizations.Team
  alias Gotham.Accounts.Role

  action_fallback GothamWeb.FallbackController

  def index(conn, _params) do
    teams = Organizations.list_teams()
    render(conn, :index, teams: teams)
  end

  # Create a new team only by admins/manager role
  def create(conn, %{"team" => team_params}) do
    authorize_roles!(conn, [Role.admin_id(), Role.manager_id()])

    with {:ok, %Team{} = team} <- Organizations.create_team(team_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/teams/#{team}")
      |> render(:show, team: team)
    end
  end

  def show(conn, %{"id" => id}) do
    team = Organizations.get_team!(id)
    render(conn, :show, team: team)
  end

  def update(conn, %{"id" => id, "team" => team_params}) do
    authorize_roles!(conn, [Role.admin_id(), Role.manager_id()])
    team = Organizations.get_team!(id)

    with {:ok, %Team{} = team} <- Organizations.update_team(team, team_params) do
      render(conn, :show, team: team)
    end
  end

  def delete(conn, %{"id" => id}) do
    authorize_roles!(conn, [Role.admin_id()])
    team = Organizations.get_team!(id)

    with {:ok, %Team{}} <- Organizations.delete_team(team) do
      send_resp(conn, :no_content, "")
    end
  end

  # Only admin can assign a manager to a team
  def assign_manager(conn, %{"id" => id, "manager_id" => manager_id}) do
    authorize_roles!(conn, [Role.admin_id()])
    team = Organizations.get_team!(id)

    with {:ok, %Team{} = team} <- Organizations.set_team_manager(team, manager_id) do
      render(conn, :show, team: team)
    end
  end

  # Manager can mark active or dismissed; cascade dismiss logic will be handled elsewhere
  def set_status(conn, %{"id" => id, "status" => status}) do
    authorize_roles!(conn, [Role.admin_id(), Role.manager_id()])
    team = Organizations.get_team!(id)

    with {:ok, %Team{} = team} <- Organizations.set_team_status(team, status) do
      render(conn, :show, team: team)
    end
  end

  defp authorize_roles!(conn, allowed_role_ids) do
    case conn.assigns[:current_user] do
      %{role_id: role_id} -> if role_id in allowed_role_ids, do: :ok, else: conn |> forbid()
      _ -> conn |> forbid()
    end
  end

  defp forbid(conn) do
    conn
    |> put_status(:forbidden)
    |> json(%{errors: [%{detail: "forbidden"}]})
    |> halt()
  end
end
