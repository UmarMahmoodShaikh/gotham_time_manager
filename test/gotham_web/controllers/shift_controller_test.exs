defmodule GothamWeb.ShiftControllerTest do
  use GothamWeb.ConnCase

  import Gotham.SchedulingFixtures
  alias Gotham.Scheduling.Shift

  @create_attrs %{
    name: "some name",
    is_night_shift: true,
    is_constraint_hour: true
  }
  @update_attrs %{
    name: "some updated name",
    is_night_shift: false,
    is_constraint_hour: false
  }
  @invalid_attrs %{name: nil, is_night_shift: nil, is_constraint_hour: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all shifts", %{conn: conn} do
      conn = get(conn, ~p"/api/shifts")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create shift" do
    test "renders shift when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/shifts", shift: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/shifts/#{id}")

      assert %{
               "id" => ^id,
               "is_constraint_hour" => true,
               "is_night_shift" => true,
               "name" => "some name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/shifts", shift: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update shift" do
    setup [:create_shift]

    test "renders shift when data is valid", %{conn: conn, shift: %Shift{id: id} = shift} do
      conn = put(conn, ~p"/api/shifts/#{shift}", shift: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/shifts/#{id}")

      assert %{
               "id" => ^id,
               "is_constraint_hour" => false,
               "is_night_shift" => false,
               "name" => "some updated name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, shift: shift} do
      conn = put(conn, ~p"/api/shifts/#{shift}", shift: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete shift" do
    setup [:create_shift]

    test "deletes chosen shift", %{conn: conn, shift: shift} do
      conn = delete(conn, ~p"/api/shifts/#{shift}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/shifts/#{shift}")
      end
    end
  end

  defp create_shift(_) do
    shift = shift_fixture()

    %{shift: shift}
  end
end
