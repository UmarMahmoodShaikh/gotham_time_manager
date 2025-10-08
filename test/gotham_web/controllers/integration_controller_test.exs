defmodule GothamWeb.IntegrationControllerTest do
  use GothamWeb.ConnCase

  import Gotham.IntegrationsFixtures
  alias Gotham.Integrations.Integration

  @create_attrs %{
    system_name: "some system_name",
    last_trigger_time: ~U[2025-10-06 09:03:00Z],
    is_active: true
  }
  @update_attrs %{
    system_name: "some updated system_name",
    last_trigger_time: ~U[2025-10-07 09:03:00Z],
    is_active: false
  }
  @invalid_attrs %{system_name: nil, last_trigger_time: nil, is_active: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all integrations", %{conn: conn} do
      conn = get(conn, ~p"/api/integrations")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create integration" do
    test "renders integration when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/integrations", integration: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/integrations/#{id}")

      assert %{
               "id" => ^id,
               "is_active" => true,
               "last_trigger_time" => "2025-10-06T09:03:00Z",
               "system_name" => "some system_name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/integrations", integration: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update integration" do
    setup [:create_integration]

    test "renders integration when data is valid", %{
      conn: conn,
      integration: %Integration{id: id} = integration
    } do
      conn = put(conn, ~p"/api/integrations/#{integration}", integration: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/integrations/#{id}")

      assert %{
               "id" => ^id,
               "is_active" => false,
               "last_trigger_time" => "2025-10-07T09:03:00Z",
               "system_name" => "some updated system_name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, integration: integration} do
      conn = put(conn, ~p"/api/integrations/#{integration}", integration: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete integration" do
    setup [:create_integration]

    test "deletes chosen integration", %{conn: conn, integration: integration} do
      conn = delete(conn, ~p"/api/integrations/#{integration}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/integrations/#{integration}")
      end
    end
  end

  defp create_integration(_) do
    integration = integration_fixture()

    %{integration: integration}
  end
end
