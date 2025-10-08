defmodule GothamWeb.PermissionControllerTest do
  use GothamWeb.ConnCase

  import Gotham.AccountsFixtures
  alias Gotham.Accounts.Permission

  @create_attrs %{
    permission_level: "some permission_level"
  }
  @update_attrs %{
    permission_level: "some updated permission_level"
  }
  @invalid_attrs %{permission_level: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all permissions", %{conn: conn} do
      conn = get(conn, ~p"/api/permissions")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create permission" do
    test "renders permission when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/permissions", permission: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/permissions/#{id}")

      assert %{
               "id" => ^id,
               "permission_level" => "some permission_level"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/permissions", permission: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update permission" do
    setup [:create_permission]

    test "renders permission when data is valid", %{
      conn: conn,
      permission: %Permission{id: id} = permission
    } do
      conn = put(conn, ~p"/api/permissions/#{permission}", permission: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/permissions/#{id}")

      assert %{
               "id" => ^id,
               "permission_level" => "some updated permission_level"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, permission: permission} do
      conn = put(conn, ~p"/api/permissions/#{permission}", permission: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete permission" do
    setup [:create_permission]

    test "deletes chosen permission", %{conn: conn, permission: permission} do
      conn = delete(conn, ~p"/api/permissions/#{permission}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/permissions/#{permission}")
      end
    end
  end

  defp create_permission(_) do
    permission = permission_fixture()

    %{permission: permission}
  end
end
