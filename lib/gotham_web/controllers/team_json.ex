defmodule GothamWeb.TeamJSON do
  alias Gotham.Organizations.Team

  def index(%{teams: teams}), do: %{data: for(t <- teams, do: data(t))}
  def show(%{team: team}), do: %{data: data(team)}

  defp data(%Team{} = team) do
    %{
      id: team.id,
      name: team.name,
      status: team.status,
      manager_id: team.manager_id,
      project_ids: Enum.map(team.projects || [], & &1.id)
    }
  end
end
