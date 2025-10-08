defmodule GothamWeb.WorkingTimeControllerTest do
  use GothamWeb.ConnCase

  import Gotham.TimeTrackingFixtures
  alias Gotham.TimeTracking.WorkingTime

  @create_attrs %{
    start_time: ~U[2025-10-06 08:56:00Z],
    end_time: ~U[2025-10-06 08:56:00Z],
    is_manual_entry: true,
    validation_status: "some validation_status",
    unpaid_overtime_hours: "120.5",
    is_transition_time: true
  }
  @update_attrs %{
    start_time: ~U[2025-10-07 08:56:00Z],
    end_time: ~U[2025-10-07 08:56:00Z],
    is_manual_entry: false,
    validation_status: "some updated validation_status",
    unpaid_overtime_hours: "456.7",
    is_transition_time: false
  }
  @invalid_attrs %{
    start_time: nil,
    end_time: nil,
    is_manual_entry: nil,
    validation_status: nil,
    unpaid_overtime_hours: nil,
    is_transition_time: nil
  }

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all working_times", %{conn: conn} do
      conn = get(conn, ~p"/api/working_times")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create working_time" do
    test "renders working_time when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/working_times", working_time: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/working_times/#{id}")

      assert %{
               "id" => ^id,
               "end_time" => "2025-10-06T08:56:00Z",
               "is_manual_entry" => true,
               "is_transition_time" => true,
               "start_time" => "2025-10-06T08:56:00Z",
               "unpaid_overtime_hours" => "120.5",
               "validation_status" => "some validation_status"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/working_times", working_time: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update working_time" do
    setup [:create_working_time]

    test "renders working_time when data is valid", %{
      conn: conn,
      working_time: %WorkingTime{id: id} = working_time
    } do
      conn = put(conn, ~p"/api/working_times/#{working_time}", working_time: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/working_times/#{id}")

      assert %{
               "id" => ^id,
               "end_time" => "2025-10-07T08:56:00Z",
               "is_manual_entry" => false,
               "is_transition_time" => false,
               "start_time" => "2025-10-07T08:56:00Z",
               "unpaid_overtime_hours" => "456.7",
               "validation_status" => "some updated validation_status"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, working_time: working_time} do
      conn = put(conn, ~p"/api/working_times/#{working_time}", working_time: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete working_time" do
    setup [:create_working_time]

    test "deletes chosen working_time", %{conn: conn, working_time: working_time} do
      conn = delete(conn, ~p"/api/working_times/#{working_time}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/working_times/#{working_time}")
      end
    end
  end

  defp create_working_time(_) do
    working_time = working_time_fixture()

    %{working_time: working_time}
  end
end
