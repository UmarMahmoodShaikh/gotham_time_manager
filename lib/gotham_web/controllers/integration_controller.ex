defmodule GothamWeb.IntegrationController do
  use GothamWeb, :controller
  alias Gotham.Integrations
  action_fallback GothamWeb.FallbackController
  def parse_bool("true"), do: true
  def parse_bool("false"), do: false
  # or raise, or default
  def parse_bool(), do: nil

  def index(conn, params) do
    status = Map.get(params, "status", nil)

    cond do
      status == nil ->
        render(conn, :index, integrations: Integrations.list_integrations())

      parse_bool(String.downcase(status)) == true ->
        render(conn, :index, integrations: Integrations.active_integrations())

      parse_bool(String.downcase(status)) == false ->
        render(conn, :index, integrations: Integrations.in_active_integrations())
    end
  end

  def show(conn, %{"id" => id}) do
    integration = Integrations.get_integration!(id)
    render(conn, :show, integration: integration)
  end

  def delete(conn, %{"id" => id}) do
    integration = Integrations.get_integration!(id)

    with {:ok, _} <- Integrations.delete_integration(integration) do
      send_resp(conn, :no_content, "")
    end
  end

  def batsignal(conn, %{"signal" => %{"system_name" => system_name} = signal_params}) do
    full_params = Map.merge(%{"last_trigger_time" => DateTime.utc_now()}, signal_params)

    case Integrations.get_integration_by_name(system_name) do
      nil ->
        with {:ok, integration} <- Integrations.create_integration(full_params) do
          conn
          |> put_status(:created)
          |> put_resp_header("location", ~p"/api/integrations/#{integration}")
          |> render(:show, integration: integration)
        end

      %{} = integration ->
        with {:ok, integration} <- Integrations.update_integration(integration, full_params) do
          conn
          |> put_status(:ok)
          |> put_resp_header("location", ~p"/api/integrations/#{integration}")
          |> render(:show, integration: integration)
        end
    end
  end
end
