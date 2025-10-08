defmodule Gotham.Integrations do
  @moduledoc """
  The Integrations context.
  """

  import Ecto.Query, warn: false
  alias Gotham.Repo
  alias Gotham.Integrations.Integration

  @doc """
  Returns the list of integrations.
  """
  def list_integrations do
    Repo.all(Integration)
  end

  @doc """
  Gets a single integration by ID.

  Raises `Ecto.NoResultsError` if the integration does not exist.
  """
  def get_integration!(id), do: Repo.get!(Integration, id)

  @doc """
  Creates a new integration.
  """
  def create_integration(attrs \\ %{}) do
    %Integration{}
    |> Integration.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates an existing integration.
  """
  def update_integration(%Integration{} = integration, attrs) do
    integration
    |> Integration.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes an integration.
  """
  def delete_integration(%Integration{} = integration) do
    Repo.delete(integration)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking integration changes.
  """
  def change_integration(%Integration{} = integration, attrs \\ %{}) do
    Integration.changeset(integration, attrs)
  end

  def get_integration_by_name(system_name) do
    Repo.get_by(Integration, system_name: system_name)
  end

  def active_integrations do
    Repo.all_by(Integration, is_active: true)
  end

  def in_active_integrations do
    Repo.all_by(Integration, is_active: false)
  end
end
