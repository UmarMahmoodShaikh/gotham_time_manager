defmodule GothamWeb.LeaveController do
  use GothamWeb, :controller

  alias Gotham.Scheduling
  alias Gotham.Scheduling.Leave

  action_fallback GothamWeb.FallbackController

  def index(conn, _params) do
    leaves = Scheduling.list_leaves()
    render(conn, :index, leaves: leaves)
  end

  def create(conn, %{"leave" => leave_params}) do
    with {:ok, %Leave{} = leave} <- Scheduling.create_leave(leave_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/leaves/#{leave}")
      |> render(:show, leave: leave)
    end
  end

  def show(conn, %{"id" => id}) do
    leave = Scheduling.get_leave!(id)
    render(conn, :show, leave: leave)
  end

  def update(conn, %{"id" => id, "leave" => leave_params}) do
    leave = Scheduling.get_leave!(id)

    with {:ok, %Leave{} = leave} <- Scheduling.update_leave(leave, leave_params) do
      render(conn, :show, leave: leave)
    end
  end

  def delete(conn, %{"id" => id}) do
    leave = Scheduling.get_leave!(id)

    with {:ok, %Leave{}} <- Scheduling.delete_leave(leave) do
      send_resp(conn, :no_content, "")
    end
  end
end
