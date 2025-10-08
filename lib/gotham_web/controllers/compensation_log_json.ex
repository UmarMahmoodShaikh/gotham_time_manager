defmodule GothamWeb.CompensationLogJSON do
  alias Gotham.Payroll.CompensationLog

  @doc """
  Renders a list of compensation_logs.
  """
  def index(%{compensation_logs: compensation_logs}) do
    %{data: for(compensation_log <- compensation_logs, do: data(compensation_log))}
  end

  @doc """
  Renders a single compensation_log.
  """
  def show(%{compensation_log: compensation_log}) do
    %{data: data(compensation_log)}
  end

  defp data(%CompensationLog{} = compensation_log) do
    %{
      id: compensation_log.id,
      pay_rate_type: compensation_log.pay_rate_type,
      hours_calculated: compensation_log.hours_calculated
    }
  end
end
