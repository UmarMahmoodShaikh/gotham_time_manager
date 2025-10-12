defmodule GothamWeb.PayrollController do
  use GothamWeb, :controller

  alias Gotham.Payroll

  # GET /api/payroll/summary
  def summary(conn, params) do
    current_user = conn.assigns.current_user

    {start_date, end_date} = get_date_range(params)

    # Only allow users to see their own payroll or managers/admins to see others
    user_id = if current_user.role_id in [2, 3] do
      Map.get(params, "user_id", current_user.id)
    else
      current_user.id
    end

    payroll_summary = Payroll.get_payroll_summary(user_id, start_date, end_date)

    conn
    |> put_status(:ok)
    |> json(%{
      data: payroll_summary,
      period: %{
        start_date: start_date,
        end_date: end_date
      }
    })
  end

  # GET /api/payroll/history
  def history(conn, params) do
    current_user = conn.assigns.current_user

    # Only allow users to see their own payroll history
    user_id = if current_user.role_id in [2, 3] do
      Map.get(params, "user_id", current_user.id)
    else
      current_user.id
    end

    page = Map.get(params, "page", "1") |> String.to_integer()
    limit = Map.get(params, "limit", "20") |> String.to_integer()

    {payroll_history, meta} = Payroll.get_payroll_history(user_id, page, limit)

    conn
    |> put_status(:ok)
    |> json(%{
      data: payroll_history,
      meta: meta
    })
  end

  # POST /api/payroll/generate (Admin only)
  def generate(conn, params) do
    current_user = conn.assigns.current_user

    if current_user.role_id != 3 do
      conn
      |> put_status(:forbidden)
      |> json(%{error: "Access denied"})
    else
      {start_date, end_date} = get_date_range(params)

      case Payroll.generate_payroll(start_date, end_date) do
        {:ok, payroll_data} ->
          conn
          |> put_status(:created)
          |> json(%{
            message: "Payroll generated successfully",
            data: payroll_data
          })

        {:error, reason} ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{
            error: "Failed to generate payroll",
            reason: reason
          })
      end
    end
  end

  # GET /api/payroll/rates (Admin/HR only)
  def rates(conn, _params) do
    current_user = conn.assigns.current_user

    if current_user.role_id not in [2, 3] do
      conn
      |> put_status(:forbidden)
      |> json(%{error: "Access denied"})
    else
      rates = Payroll.get_pay_rates()

      conn
      |> put_status(:ok)
      |> json(%{
        data: rates
      })
    end
  end

  # PUT /api/payroll/rates/:user_id (Admin only)
  def update_rates(conn, %{"user_id" => user_id} = params) do
    current_user = conn.assigns.current_user

    if current_user.role_id != 3 do
      conn
      |> put_status(:forbidden)
      |> json(%{error: "Access denied"})
    else
      case Payroll.update_pay_rates(user_id, params) do
        {:ok, rates} ->
          conn
          |> put_status(:ok)
          |> json(%{
            message: "Pay rates updated successfully",
            data: rates
          })

        {:error, changeset} ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{
            error: "Failed to update pay rates",
            details: format_errors(changeset)
          })
      end
    end
  end

  defp get_date_range(params) do
    start_date = case Map.get(params, "start_date") do
      nil ->
        Date.utc_today() |> Date.beginning_of_month()
      date_string ->
        case Date.from_iso8601(date_string) do
          {:ok, date} -> date
          _ -> Date.utc_today() |> Date.beginning_of_month()
        end
    end

    end_date = case Map.get(params, "end_date") do
      nil ->
        Date.utc_today() |> Date.end_of_month()
      date_string ->
        case Date.from_iso8601(date_string) do
          {:ok, date} -> date
          _ -> Date.utc_today() |> Date.end_of_month()
        end
    end

    {start_date, end_date}
  end

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
