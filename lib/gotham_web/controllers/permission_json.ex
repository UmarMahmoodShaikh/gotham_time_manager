defmodule GothamWeb.PermissionJSON do
  alias Gotham.Accounts.Permission

  @doc """
  Renders a list of permissions.
  """
  def index(%{permissions: permissions}) do
    %{data: for(permission <- permissions, do: data(permission))}
  end

  @doc """
  Renders a single permission.
  """
  def show(%{permission: permission}) do
    %{data: data(permission)}
  end

  defp data(%Permission{} = permission) do
    %{
      permission_level: permission.permission_level
    }
  end
end
