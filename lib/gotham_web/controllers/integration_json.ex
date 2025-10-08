defmodule GothamWeb.IntegrationJSON do
  alias Gotham.Integrations.Integration

  @doc """
  Renders a list of integrations.
  """
  def index(%{integrations: integrations}) do
    %{data: for(integration <- integrations, do: data(integration))}
  end

  @doc """
  Renders a single integration.
  """
  def show(%{integration: integration}) do
    %{data: data(integration)}
  end

  defp data(%Integration{} = integration) do
    %{
      system_name: integration.system_name,
      last_trigger_time: integration.last_trigger_time,
      is_active: integration.is_active
    }
  end
end
