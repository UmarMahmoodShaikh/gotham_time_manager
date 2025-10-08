defmodule GothamWeb.CompensationLogController do
  use GothamWeb, :controller

  alias Gotham.Payroll
  alias Gotham.Payroll.CompensationLog

  action_fallback GothamWeb.FallbackController

  def index(conn, _params) do
    compensation_logs = Payroll.list_compensation_logs()
    render(conn, :index, compensation_logs: compensation_logs)
  end

  def create(conn, %{"compensation_log" => compensation_log_params}) do
    with {:ok, %CompensationLog{} = compensation_log} <-
           Payroll.create_compensation_log(compensation_log_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/compensation_logs/#{compensation_log}")
      |> render(:show, compensation_log: compensation_log)
    end
  end

  def show(conn, %{"id" => id}) do
    compensation_log = Payroll.get_compensation_log!(id)
    render(conn, :show, compensation_log: compensation_log)
  end

  def update(conn, %{"id" => id, "compensation_log" => compensation_log_params}) do
    compensation_log = Payroll.get_compensation_log!(id)

    with {:ok, %CompensationLog{} = compensation_log} <-
           Payroll.update_compensation_log(compensation_log, compensation_log_params) do
      render(conn, :show, compensation_log: compensation_log)
    end
  end

  def delete(conn, %{"id" => id}) do
    compensation_log = Payroll.get_compensation_log!(id)

    with {:ok, %CompensationLog{}} <- Payroll.delete_compensation_log(compensation_log) do
      send_resp(conn, :no_content, "")
    end
  end
end
