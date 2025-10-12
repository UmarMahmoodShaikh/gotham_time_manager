defmodule GothamWeb.BreakController do
  use GothamWeb, :controller

  alias Gotham.TimeTracking.Breaks

  # POST /api/breaks/start
  def start_break(conn, params) do
    current_user = conn.assigns.current_user
    break_type = Map.get(params, "break_type", "regular") # regular, lunch, emergency

    case Breaks.start_break(current_user.id, break_type) do
      {:ok, break_entry} ->
        conn
        |> put_status(:created)
        |> json(%{
          message: "Break started successfully",
          data: %{
            id: break_entry.id,
            user_id: break_entry.user_id,
            break_type: break_entry.break_type,
            start_time: break_entry.start_time,
            status: "active"
          }
        })

      {:error, :already_on_break} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "User is already on a break"})

      {:error, :not_clocked_in} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "Must be clocked in to take a break"})

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{
          error: "Failed to start break",
          details: format_errors(changeset)
        })
    end
  end

  # POST /api/breaks/end
  def end_break(conn, _params) do
    current_user = conn.assigns.current_user

    case Breaks.end_break(current_user.id) do
      {:ok, break_entry} ->
        conn
        |> put_status(:ok)
        |> json(%{
          message: "Break ended successfully",
          data: %{
            id: break_entry.id,
            user_id: break_entry.user_id,
            break_type: break_entry.break_type,
            start_time: break_entry.start_time,
            end_time: break_entry.end_time,
            duration_minutes: break_entry.duration_minutes,
            status: "completed"
          }
        })

      {:error, :no_active_break} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "No active break found"})

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{
          error: "Failed to end break",
          details: format_errors(changeset)
        })
    end
  end

  # GET /api/breaks/status
  def status(conn, _params) do
    current_user = conn.assigns.current_user

    case Breaks.get_active_break(current_user.id) do
      nil ->
        conn
        |> put_status(:ok)
        |> json(%{
          status: "not_on_break",
          active_break: nil
        })

      break_entry ->
        elapsed_minutes = DateTime.diff(DateTime.utc_now(), break_entry.start_time, :second) / 60

        conn
        |> put_status(:ok)
        |> json(%{
          status: "on_break",
          active_break: %{
            id: break_entry.id,
            break_type: break_entry.break_type,
            start_time: break_entry.start_time,
            elapsed_minutes: Float.round(elapsed_minutes, 1)
          }
        })
    end
  end

  # GET /api/breaks/history
  def history(conn, params) do
    current_user = conn.assigns.current_user
    start_date = Map.get(params, "start_date")
    end_date = Map.get(params, "end_date")
    page = Map.get(params, "page", "1") |> String.to_integer()
    limit = Map.get(params, "limit", "20") |> String.to_integer()

    filters = %{
      user_id: current_user.id,
      start_date: start_date,
      end_date: end_date,
      page: page,
      limit: limit
    }

    {break_entries, meta} = Breaks.list_break_history(filters)

    conn
    |> put_status(:ok)
    |> json(%{
      data: break_entries,
      meta: meta
    })
  end

  # GET /api/breaks/summary
  def summary(conn, params) do
    current_user = conn.assigns.current_user
    date = Map.get(params, "date", Date.utc_today() |> Date.to_string())

    case Date.from_iso8601(date) do
      {:ok, summary_date} ->
        summary = Breaks.get_daily_break_summary(current_user.id, summary_date)

        conn
        |> put_status(:ok)
        |> json(%{
          data: summary
        })

      {:error, _} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "Invalid date format. Use YYYY-MM-DD"})
    end
  end

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
