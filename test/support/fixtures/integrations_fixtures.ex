defmodule Gotham.IntegrationsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Gotham.Integrations` context.
  """

  @doc """
  Generate a integration.
  """
  def integration_fixture(attrs \\ %{}) do
    {:ok, integration} =
      attrs
      |> Enum.into(%{
        is_active: true,
        last_trigger_time: ~U[2025-10-06 08:52:00Z],
        system_name: "some system_name"
      })
      |> Gotham.Integrations.create_integration()

    integration
  end
end
