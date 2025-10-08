defmodule Gotham.Payroll do
  @moduledoc """
  The Payroll context.
  """

  import Ecto.Query, warn: false
  alias Gotham.Repo
  alias Gotham.Payroll.CompensationLog

  @doc """
  Returns the list of compensation logs.
  """
  def list_compensation_logs do
    Repo.all(CompensationLog)
  end

  @doc """
  Gets a single compensation log by ID.

  Raises `Ecto.NoResultsError` if the log does not exist.
  """
  def get_compensation_log!(id), do: Repo.get!(CompensationLog, id)

  @doc """
  Creates a compensation log.
  """
  def create_compensation_log(attrs \\ %{}) do
    %CompensationLog{}
    |> CompensationLog.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a compensation log.
  """
  def update_compensation_log(%CompensationLog{} = compensation_log, attrs) do
    compensation_log
    |> CompensationLog.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a compensation log.
  """
  def delete_compensation_log(%CompensationLog{} = compensation_log) do
    Repo.delete(compensation_log)
  end

  @doc """
  Returns a changeset for tracking compensation log changes.
  """
  def change_compensation_log(%CompensationLog{} = compensation_log, attrs \\ %{}) do
    CompensationLog.changeset(compensation_log, attrs)
  end
end
