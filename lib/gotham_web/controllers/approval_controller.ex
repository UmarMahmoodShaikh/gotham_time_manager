defmodule GothamWeb.ApprovalController do
  use GothamWeb, :controller

  alias Gotham.TimeTracking

  # GET /api/approvals/pending
  def pending(conn, params) do
    current_user = conn.assigns.current_user

    # Only managers and admins can see pending approvals
    if current_user.role_id in [2, 3] do
      filters = %{
        status: "pending",
        manager_id: if(current_user.role_id == 2, do: current_user.id, else: nil),
        page: Map.get(params, "page", "1") |> String.to_integer(),
        limit: Map.get(params, "limit", "20") |> String.to_integer()
      }

      {entries, meta} = TimeTracking.list_pending_approvals(filters)

      conn
      |> put_status(:ok)
      |> json(%{
        data: entries,
        meta: meta
      })
    else
      conn
      |> put_status(:forbidden)
      |> json(%{error: "Access denied"})
    end
  end

  # POST /api/approvals/:id/approve
  def approve(conn, %{"id" => id} = params) do
    current_user = conn.assigns.current_user
    notes = Map.get(params, "notes")

    case TimeTracking.approve_time_entry(id, current_user.id, notes) do
      {:ok, time_entry} ->
        conn
        |> put_status(:ok)
        |> json(%{
          message: "Time entry approved successfully",
          data: time_entry
        })

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{
          error: "Approval failed",
          details: format_errors(changeset)
        })
    end
  end

  # POST /api/approvals/:id/reject
  def reject(conn, %{"id" => id} = params) do
    current_user = conn.assigns.current_user
    reason = Map.get(params, "reason", "No reason provided")

    case TimeTracking.reject_time_entry(id, current_user.id, reason) do
      {:ok, time_entry} ->
        conn
        |> put_status(:ok)
        |> json(%{
          message: "Time entry rejected",
          data: time_entry
        })

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{
          error: "Rejection failed",
          details: format_errors(changeset)
        })
    end
  end

  # POST /api/approvals/bulk-approve
  def bulk_approve(conn, %{"entry_ids" => entry_ids} = params) do
    current_user = conn.assigns.current_user
    notes = Map.get(params, "notes")

    results = Enum.map(entry_ids, fn id ->
      case TimeTracking.approve_time_entry(id, current_user.id, notes) do
        {:ok, entry} -> %{id: id, status: "approved", entry: entry}
        {:error, _} -> %{id: id, status: "failed", error: "Approval failed"}
      end
    end)

    successful = Enum.count(results, &(&1.status == "approved"))
    failed = Enum.count(results, &(&1.status == "failed"))

    conn
    |> put_status(:ok)
    |> json(%{
      message: "Bulk approval completed",
      summary: %{
        total: length(entry_ids),
        successful: successful,
        failed: failed
      },
      results: results
    })
  end

  # GET /api/approvals/history
  def history(conn, params) do
    current_user = conn.assigns.current_user

    filters = %{
      approver_id: current_user.id,
      start_date: Map.get(params, "start_date"),
      end_date: Map.get(params, "end_date"),
      page: Map.get(params, "page", "1") |> String.to_integer(),
      limit: Map.get(params, "limit", "20") |> String.to_integer()
    }

    {entries, meta} = TimeTracking.list_approval_history(filters)

    conn
    |> put_status(:ok)
    |> json(%{
      data: entries,
      meta: meta
    })
  end

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
