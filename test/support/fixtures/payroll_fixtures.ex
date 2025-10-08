defmodule Gotham.PayrollFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Gotham.Payroll` context.
  """

  @doc """
  Generate a compensation_log.
  """
  def compensation_log_fixture(attrs \\ %{}) do
    {:ok, compensation_log} =
      attrs
      |> Enum.into(%{
        hours_calculated: "120.5",
        pay_rate_type: "some pay_rate_type"
      })
      |> Gotham.Payroll.create_compensation_log()

    compensation_log
  end
end
