defmodule GothamWeb.TimeTrackingController do
  use GothamWeb, :controller

  alias Gotham.TimeTracking
  alias Gotham.TimeTracking.TimeEntry

  action_fallback GothamWeb.FallbackController

  # POST /api/time-tracking/clock-in
  def clock_in(conn, params) do
    current_user = conn.assigns[:current_user]

    # Check if user is already clocked in
    case TimeTracking.get_active_entry(current_user.id) do
      nil ->
        attrs = %{
          user_id: current_user.id,
          clock_in: DateTime.utc_now(),
          work_location: Map.get(params, "work_location", "WFO"),
          notes: Map.get(params, "notes"),
          latitude: Map.get(params, "latitude"),
          longitude: Map.get(params, "longitude"),
          status: "in_progress"
        }

        with {:ok, %TimeEntry{} = entry} <- TimeTracking.create_time_entry(attrs) do
          conn
          |> put_status(:created)
          |> render(:show, time_entry: entry)
        end

      _active_entry ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "Already clocked in"})
    end
  end

  # POST /api/time-tracking/clock-out
  def clock_out(conn, params) do
    current_user = conn.assigns[:current_user]

    case TimeTracking.get_active_entry(current_user.id) do
      nil ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "Not clocked in"})

      entry ->
        clock_out_time = DateTime.utc_now()

        # Calculate total hours
        clock_in_time = entry.clock_in
        total_hours = DateTime.diff(clock_out_time, clock_in_time, :second) / 3600.0

        attrs = %{
          clock_out: clock_out_time,
          total_hours: Float.round(total_hours, 2),
          status: "completed",
          notes: Map.get(params, "notes"),
          latitude: Map.get(params, "latitude"),
          longitude: Map.get(params, "longitude")
        }

        with {:ok, %TimeEntry{} = updated_entry} <- TimeTracking.update_time_entry(entry, attrs) do
          conn
          |> render(:show, time_entry: updated_entry)
        end
    end
  end

  # GET /api/time-tracking/status
  def status(conn, _params) do
    current_user = conn.assigns[:current_user]

    case TimeTracking.get_active_entry(current_user.id) do
      nil ->
        conn
        |> json(%{
          data: %{
            is_clocked_in: false,
            current_entry: nil
          }
        })

      entry ->
        clock_in_time = entry.clock_in
        elapsed_hours = DateTime.diff(DateTime.utc_now(), clock_in_time, :second) / 3600.0

        conn
        |> json(%{
          data: %{
            is_clocked_in: true,
            current_entry: %{
              id: entry.id,
              clock_in: entry.clock_in,
              work_location: entry.work_location,
              elapsed_hours: Float.round(elapsed_hours, 2)
            }
          }
        })
    end
  end

  # GET /api/time-tracking/entries
  def entries(conn, params) do
    current_user = conn.assigns[:current_user]

    # Check if user has permission to view other users' entries
    user_id = case Map.get(params, "user_id") do
      nil -> current_user.id
      requested_user_id ->
        if can_view_user_entries?(current_user, requested_user_id) do
          String.to_integer(requested_user_id)
        else
          current_user.id
        end
    end

    filters = %{
      user_id: user_id,
      start_date: Map.get(params, "start_date"),
      end_date: Map.get(params, "end_date"),
      status: Map.get(params, "status"),
      page: Map.get(params, "page", "1") |> String.to_integer(),
      limit: Map.get(params, "limit", "20") |> String.to_integer()
    }

    {entries, meta} = TimeTracking.list_time_entries(filters)

    conn
    |> render(:index, time_entries: entries, meta: meta)
  end

  # POST /api/time-tracking/entries/manual
  def create_manual_entry(conn, params) do
    current_user = conn.assigns[:current_user]

    # Parse date and times
    date = Date.from_iso8601!(params["date"])
    {:ok, clock_in_time} = Time.from_iso8601(params["clock_in"])
    {:ok, clock_out_time} = Time.from_iso8601(params["clock_out"])

    # Convert to DateTime
    clock_in = DateTime.new!(date, clock_in_time, "Etc/UTC")
    clock_out = DateTime.new!(date, clock_out_time, "Etc/UTC")

    # Calculate total hours
    total_hours = DateTime.diff(clock_out, clock_in, :second) / 3600.0

    attrs = %{
      user_id: current_user.id,
      clock_in: clock_in,
      clock_out: clock_out,
      total_hours: Float.round(total_hours, 2),
      work_location: Map.get(params, "work_location", "WFO"),
      justification: Map.get(params, "justification"),
      is_manual: true,
      status: "pending"
    }

    with {:ok, %TimeEntry{} = entry} <- TimeTracking.create_time_entry(attrs) do
      conn
      |> put_status(:created)
      |> render(:show, time_entry: entry)
    end
  end

  # PUT /api/time-tracking/entries/:id
  def update_entry(conn, %{"id" => id} = params) do
    current_user = conn.assigns[:current_user]

    entry = TimeTracking.get_time_entry!(id)

    if can_edit_entry?(current_user, entry) do
      case TimeTracking.update_time_entry(entry, params) do
        {:ok, updated_entry} ->
          conn
          |> render(:show, time_entry: updated_entry)

        {:error, changeset} ->
          conn
          |> put_status(:unprocessable_entity)
          |> render(:error, changeset: changeset)
      end
    else
      conn
      |> put_status(:forbidden)
      |> json(%{error: "Cannot edit this entry"})
    end
  end

  # DELETE /api/time-tracking/entries/:id
  def delete_entry(conn, %{"id" => id}) do
    current_user = conn.assigns[:current_user]

    entry = TimeTracking.get_time_entry!(id)

    if can_delete_entry?(current_user, entry) do
      case TimeTracking.delete_time_entry(entry) do
        {:ok, _entry} ->
          send_resp(conn, :no_content, "")

        {:error, changeset} ->
          conn
          |> put_status(:unprocessable_entity)
          |> render(:error, changeset: changeset)
      end
    else
      conn
      |> put_status(:forbidden)
      |> json(%{error: "Cannot delete this entry"})
    end
  end

  # Authorization helpers
  defp can_view_user_entries?(current_user, _user_id) do
    current_user.role_id in [
      Gotham.Accounts.Role.admin_id(),
      Gotham.Accounts.Role.manager_id(),
      Gotham.Accounts.Role.hr_id()
    ]
  end

  defp can_edit_entry?(current_user, entry) do
    # Users can edit their own pending entries
    # Admins/HR can edit any entry
    (entry.user_id == current_user.id and entry.status == "pending") or
    current_user.role_id in [
      Gotham.Accounts.Role.admin_id(),
      Gotham.Accounts.Role.hr_id()
    ]
  end

  defp can_delete_entry?(current_user, entry) do
    # Users can delete their own pending entries
    # Admins can delete any pending entry
    (entry.user_id == current_user.id and entry.status == "pending") or
    current_user.role_id == Gotham.Accounts.Role.admin_id()
  end
end
