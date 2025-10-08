defmodule GothamWeb.WorkingTimeController do
  use GothamWeb, :controller

  alias Gotham.TimeTracking
  alias Gotham.TimeTracking.WorkingTime

  action_fallback GothamWeb.FallbackController

  def index(conn, %{"userID" => user_id}) do
    user_id = normalize_id(user_id)
    working_times = TimeTracking.list_working_times_by_user(user_id)
    render(conn, :index, working_times: working_times)
  end

  def index(conn, _params) do
    working_times = TimeTracking.list_working_times()
    render(conn, :index, working_times: working_times)
  end

  def create(conn, %{"userID" => user_id, "working_time" => working_time_params}) do
    user_id = normalize_id(user_id)

    with {:ok, %WorkingTime{} = working_time} <-
           TimeTracking.create_working_time_for_user(user_id, working_time_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/workingtime/#{user_id}/#{working_time}")
      |> render(:show, working_time: working_time)
    end
  end

  def create(conn, %{"working_time" => working_time_params}) do
    with {:ok, %WorkingTime{} = working_time} <-
           TimeTracking.create_working_time(working_time_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/working_times/#{working_time}")
      |> render(:show, working_time: working_time)
    end
  end

  def show(conn, %{"userID" => user_id, "id" => id}) do
    user_id = normalize_id(user_id)
    id = normalize_id(id)
    working_time = TimeTracking.get_working_time_for_user!(user_id, id)
    render(conn, :show, working_time: working_time)
  end

  def show(conn, %{"id" => id}) do
    working_time = TimeTracking.get_working_time!(id)
    render(conn, :show, working_time: working_time)
  end

  defp normalize_id(id) when is_integer(id), do: id

  defp normalize_id(id) when is_binary(id) do
    case Integer.parse(id) do
      {int, _} -> int
      :error -> id
    end
  end

  def update(conn, %{"id" => id, "working_time" => working_time_params}) do
    working_time = TimeTracking.get_working_time!(id)

    with {:ok, %WorkingTime{} = working_time} <-
           TimeTracking.update_working_time(working_time, working_time_params) do
      render(conn, :show, working_time: working_time)
    end
  end

  def delete(conn, %{"id" => id}) do
    working_time = TimeTracking.get_working_time!(id)

    with {:ok, %WorkingTime{}} <- TimeTracking.delete_working_time(working_time) do
      send_resp(conn, :no_content, "")
    end
  end

  # POST /logs/overtime/unpaid
  def log_unpaid_overtime(conn, %{"overtime" => %{"date" => date_str, "hours" => hours}}) do
    user = conn.assigns[:current_user]

    with {:ok, date} <- Date.from_iso8601(date_str),
         {:ok, naive} <- NaiveDateTime.new(date, ~T[00:00:00]),
         {:ok, start_dt} <- DateTime.from_naive(naive, "Etc/UTC"),
         {:ok, %WorkingTime{} = working_time} <-
           TimeTracking.create_working_time_for_user(user.id, %{
             "start_time" => start_dt,
             "unpaid_overtime_hours" => hours,
             "is_manual_entry" => true,
             "validation_status" => "pending",
             "is_transition_time" => false
           }) do
      conn
      |> put_status(:created)
      |> render(:show, working_time: working_time)
    else
      _ ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: [%{detail: "invalid payload"}]})
    end
  end

  # GET /payroll/calculation/rates
  def calculation_rates(conn, _params) do
    # Example static rates; adapt to pull from DB/config as needed
    json(conn, %{
      data: %{
        base_hourly_rate: 11.88,
        overtime_multiplier: 1.25,
        night_shift_multiplier: 1.5,
        weekend_multiplier: 2.0,
        currency: "EUR"
      }
    })
  end

  # GET /payroll/report/:id?limit=6&offset=0
  def payroll_report(conn, %{"id" => user_id} = params) do
    user_id = normalize_id(user_id)
    limit = Map.get(params, "limit", "6") |> to_int(6)
    offset = Map.get(params, "offset", "0") |> to_int(0)

    data = Gotham.TimeTracking.payroll_monthly_detailed(user_id, limit, offset)

    json(conn, %{data: data})
  end

  defp to_int(val, _default) when is_integer(val), do: val

  defp to_int(val, default) when is_binary(val) do
    case Integer.parse(val) do
      {i, _} -> i
      :error -> default
    end
  end
end
