defmodule GothamWeb.RoleController do
  use GothamWeb, :controller

  alias Gotham.Accounts

  action_fallback GothamWeb.FallbackController

  def index(conn, _params) do
    roles = Accounts.list_roles()
    render(conn, :index, roles: roles)
  end

  def show(conn, %{"id" => id}) do
    role = Accounts.get_role!(id)
    render(conn, :show, role: role)
  end
end
