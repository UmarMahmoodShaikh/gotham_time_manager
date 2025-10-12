defmodule GothamWeb.TimeTrackingJSON do
  alias Gotham.TimeTracking.TimeEntry

  @doc """
  Renders a list of time_entries.
  """
  def index(%{time_entries: time_entries}) do
    %{data: for(time_entry <- time_entries, do: data(time_entry))}
  end

  @doc """
  Renders a single time_entry.
  """
  def show(%{time_entry: time_entry}) do
    %{data: data(time_entry)}
  end

  @doc """
  Renders clock in response.
  """
  def clock_in(%{time_entry: time_entry}) do
    %{
      message: "Clocked in successfully",
      data: %{
        id: time_entry.id,
        user_id: time_entry.user_id,
        clock_in: time_entry.clock_in,
        work_location: time_entry.work_location,
        latitude: time_entry.latitude,
        longitude: time_entry.longitude,
        status: time_entry.status
      }
    }
  end

  @doc """
  Renders clock out response.
  """
  def clock_out(%{time_entry: time_entry}) do
    %{
      message: "Clocked out successfully",
      data: %{
        id: time_entry.id,
        user_id: time_entry.user_id,
        clock_in: time_entry.clock_in,
        clock_out: time_entry.clock_out,
        total_hours: time_entry.total_hours,
        work_location: time_entry.work_location,
        notes: time_entry.notes,
        status: time_entry.status
      }
    }
  end

  @doc """
  Renders current status.
  """
  def status(%{status: "not_clocked_in"}) do
    %{
      status: "not_clocked_in",
      message: "User is not currently clocked in",
      active_entry: nil
    }
  end

  def status(%{status: "clocked_in", active_entry: active_entry}) do
    %{
      status: "clocked_in",
      message: "User is currently clocked in",
      active_entry: data(active_entry)
    }
  end

  @doc """
  Renders time entries list.
  """
  def entries(%{time_entries: time_entries, total_hours: total_hours}) do
    %{
      data: for(time_entry <- time_entries, do: data(time_entry)),
      summary: %{
        total_hours: total_hours,
        total_entries: length(time_entries)
      }
    }
  end

  @doc """
  Renders error response.
  """
  def error(%{error: :already_clocked_in}) do
    %{
      error: "already_clocked_in",
      message: "User is already clocked in"
    }
  end

  def error(%{error: :not_clocked_in}) do
    %{
      error: "not_clocked_in",
      message: "User is not currently clocked in"
    }
  end

  def error(%{error: error}) when is_binary(error) do
    %{
      error: "validation_error",
      message: error
    }
  end

  def error(%{changeset: changeset}) do
    %{
      error: "validation_error",
      message: "Invalid data provided",
      errors: format_errors(changeset)
    }
  end

  defp data(%TimeEntry{} = time_entry) do
    %{
      id: time_entry.id,
      user_id: time_entry.user_id,
      clock_in: time_entry.clock_in,
      clock_out: time_entry.clock_out,
      total_hours: time_entry.total_hours,
      work_location: time_entry.work_location,
      notes: time_entry.notes,
      latitude: time_entry.latitude,
      longitude: time_entry.longitude,
      status: time_entry.status,
      is_manual: time_entry.is_manual,
      justification: time_entry.justification,
      approved_by: time_entry.approved_by,
      approved_at: time_entry.approved_at,
      rejected_by: time_entry.rejected_by,
      rejected_at: time_entry.rejected_at,
      approval_notes: time_entry.approval_notes,
      rejection_reason: time_entry.rejection_reason,
      inserted_at: time_entry.inserted_at,
      updated_at: time_entry.updated_at
    }
  end

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
