defmodule Gotham.IntegrationsTest do
  use Gotham.DataCase

  alias Gotham.Integrations

  describe "integrations" do
    alias Gotham.Integrations.Integration

    import Gotham.IntegrationsFixtures

    @invalid_attrs %{system_name: nil, last_trigger_time: nil, is_active: nil}

    test "list_integrations/0 returns all integrations" do
      integration = integration_fixture()
      assert Integrations.list_integrations() == [integration]
    end

    test "get_integration!/1 returns the integration with given id" do
      integration = integration_fixture()
      assert Integrations.get_integration!(integration.id) == integration
    end

    test "create_integration/1 with valid data creates a integration" do
      valid_attrs = %{
        system_name: "some system_name",
        last_trigger_time: ~U[2025-10-06 08:52:00Z],
        is_active: true
      }

      assert {:ok, %Integration{} = integration} = Integrations.create_integration(valid_attrs)
      assert integration.system_name == "some system_name"
      assert integration.last_trigger_time == ~U[2025-10-06 08:52:00Z]
      assert integration.is_active == true
    end

    test "create_integration/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Integrations.create_integration(@invalid_attrs)
    end

    test "update_integration/2 with valid data updates the integration" do
      integration = integration_fixture()

      update_attrs = %{
        system_name: "some updated system_name",
        last_trigger_time: ~U[2025-10-07 08:52:00Z],
        is_active: false
      }

      assert {:ok, %Integration{} = integration} =
               Integrations.update_integration(integration, update_attrs)

      assert integration.system_name == "some updated system_name"
      assert integration.last_trigger_time == ~U[2025-10-07 08:52:00Z]
      assert integration.is_active == false
    end

    test "update_integration/2 with invalid data returns error changeset" do
      integration = integration_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Integrations.update_integration(integration, @invalid_attrs)

      assert integration == Integrations.get_integration!(integration.id)
    end

    test "delete_integration/1 deletes the integration" do
      integration = integration_fixture()
      assert {:ok, %Integration{}} = Integrations.delete_integration(integration)
      assert_raise Ecto.NoResultsError, fn -> Integrations.get_integration!(integration.id) end
    end

    test "change_integration/1 returns a integration changeset" do
      integration = integration_fixture()
      assert %Ecto.Changeset{} = Integrations.change_integration(integration)
    end
  end

  describe "integrations" do
    alias Gotham.Integrations.Integration

    import Gotham.IntegrationsFixtures

    @invalid_attrs %{system_name: nil, last_trigger_time: nil, is_active: nil}

    test "list_integrations/0 returns all integrations" do
      integration = integration_fixture()
      assert Integrations.list_integrations() == [integration]
    end

    test "get_integration!/1 returns the integration with given id" do
      integration = integration_fixture()
      assert Integrations.get_integration!(integration.id) == integration
    end

    test "create_integration/1 with valid data creates a integration" do
      valid_attrs = %{
        system_name: "some system_name",
        last_trigger_time: ~U[2025-10-06 09:03:00Z],
        is_active: true
      }

      assert {:ok, %Integration{} = integration} = Integrations.create_integration(valid_attrs)
      assert integration.system_name == "some system_name"
      assert integration.last_trigger_time == ~U[2025-10-06 09:03:00Z]
      assert integration.is_active == true
    end

    test "create_integration/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Integrations.create_integration(@invalid_attrs)
    end

    test "update_integration/2 with valid data updates the integration" do
      integration = integration_fixture()

      update_attrs = %{
        system_name: "some updated system_name",
        last_trigger_time: ~U[2025-10-07 09:03:00Z],
        is_active: false
      }

      assert {:ok, %Integration{} = integration} =
               Integrations.update_integration(integration, update_attrs)

      assert integration.system_name == "some updated system_name"
      assert integration.last_trigger_time == ~U[2025-10-07 09:03:00Z]
      assert integration.is_active == false
    end

    test "update_integration/2 with invalid data returns error changeset" do
      integration = integration_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Integrations.update_integration(integration, @invalid_attrs)

      assert integration == Integrations.get_integration!(integration.id)
    end

    test "delete_integration/1 deletes the integration" do
      integration = integration_fixture()
      assert {:ok, %Integration{}} = Integrations.delete_integration(integration)
      assert_raise Ecto.NoResultsError, fn -> Integrations.get_integration!(integration.id) end
    end

    test "change_integration/1 returns a integration changeset" do
      integration = integration_fixture()
      assert %Ecto.Changeset{} = Integrations.change_integration(integration)
    end
  end
end
