defmodule GothamWeb.ShiftController do
  use GothamWeb, :controller

  alias Gotham.Scheduling

  action_fallback GothamWeb.FallbackController

  def index(conn, _params) do
    shifts = Scheduling.list_shifts()
    render(conn, :index, shifts: shifts)
  end

  def create(conn, %{"shift" => shift_params}) do
    with {:ok, shift} <- Scheduling.create_shift(shift_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/shifts/#{shift}")
      |> render(:show, shift: shift)
    end
  end

  def show(conn, %{"id" => id}) do
    shift = Scheduling.get_shift!(id)
    render(conn, :show, shift: shift)
  end

  def update(conn, %{"id" => id, "shift" => shift_params}) do
    shift = Scheduling.get_shift!(id)

    with {:ok, shift} <- Scheduling.update_shift(shift, shift_params) do
      render(conn, :show, shift: shift)
    end
  end

  def delete(conn, %{"id" => id}) do
    shift = Scheduling.get_shift!(id)

    with {:ok, _} <- Scheduling.delete_shift(shift) do
      send_resp(conn, :no_content, "")
    end
  end

  # Router exposes:
  #   get "/audit/night_shift_alert", :night_shift_alert
  # Implement alert using Scheduling.night_shift_alert/0
  def night_shift_alert(conn, _params) do
    alert = Scheduling.night_shift_alert()
    json(conn, %{data: alert})
  end
end
