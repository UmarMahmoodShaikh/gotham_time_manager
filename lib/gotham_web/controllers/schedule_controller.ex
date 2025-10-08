defmodule GothamWeb.ScheduleController do
  use GothamWeb, :controller

  alias Gotham.Scheduling

  action_fallback GothamWeb.FallbackController

  def index(conn, _params) do
    schedules = Scheduling.list_schedules()
    render(conn, :index, schedules: schedules)
  end

  def create(conn, %{"schedule" => schedule_params}) do
    with {:ok, schedule} <- Scheduling.create_schedule(schedule_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/schedules/#{schedule}")
      |> render(:show, schedule: schedule)
    end
  end

  def show(conn, %{"id" => id}) do
    schedule = Scheduling.get_schedule!(id)
    render(conn, :show, schedule: schedule)
  end

  def update(conn, %{"id" => id, "schedule" => schedule_params}) do
    schedule = Scheduling.get_schedule!(id)

    with {:ok, schedule} <- Scheduling.update_schedule(schedule, schedule_params) do
      render(conn, :show, schedule: schedule)
    end
  end

  def delete(conn, %{"id" => id}) do
    schedule = Scheduling.get_schedule!(id)

    with {:ok, _} <- Scheduling.delete_schedule(schedule) do
      send_resp(conn, :no_content, "")
    end
  end

  # Router exposes extra endpoints:
  #   get "/schedules/:employee_id/constraints", :constraints
  #   post/put "/schedules/create_batch", :create_batch
  # Implemented below.

  def constraints(conn, %{"employee_id" => employee_id}) do
    employee_id = normalize_id(employee_id)
    constraints = Scheduling.constraints_for_employee(employee_id)
    json(conn, %{data: constraints})
  end

  def create_batch(conn, %{"schedules" => schedules}) do
    schedules = Enum.map(schedules, &normalize_schedule/1)

    case Scheduling.create_schedules_batch(schedules) do
      {:ok, created} ->
        conn
        |> put_status(:created)
        |> json(%{data: Enum.map(created, &%{id: &1.id})})

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: translate_changeset_errors(changeset)})
    end
  end

  defp normalize_id(id) when is_integer(id), do: id

  defp normalize_id(id) when is_binary(id) do
    case Integer.parse(id) do
      {int, _} -> int
      :error -> id
    end
  end

  defp normalize_schedule(%{"employee_id" => employee_id} = attrs) do
    attrs
    |> Map.put("user_id", normalize_id(employee_id))
    |> Map.delete("employee_id")
  end

  defp translate_changeset_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end
end
