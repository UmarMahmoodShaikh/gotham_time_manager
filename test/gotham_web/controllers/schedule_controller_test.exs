defmodule GothamWeb.ScheduleControllerTest do
  use GothamWeb.ConnCase

  import Gotham.SchedulingFixtures
  alias Gotham.Scheduling.Schedule

  @create_attrs %{
    start_date: ~D[2025-10-06],
    end_date: ~D[2025-10-06],
    consecutive_night_count: 42
  }
  @update_attrs %{
    start_date: ~D[2025-10-07],
    end_date: ~D[2025-10-07],
    consecutive_night_count: 43
  }
  @invalid_attrs %{start_date: nil, end_date: nil, consecutive_night_count: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all schedules", %{conn: conn} do
      conn = get(conn, ~p"/api/schedules")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create schedule" do
    test "renders schedule when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/schedules", schedule: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/schedules/#{id}")

      assert %{
               "id" => ^id,
               "consecutive_night_count" => 42,
               "end_date" => "2025-10-06",
               "start_date" => "2025-10-06"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/schedules", schedule: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update schedule" do
    setup [:create_schedule]

    test "renders schedule when data is valid", %{
      conn: conn,
      schedule: %Schedule{id: id} = schedule
    } do
      conn = put(conn, ~p"/api/schedules/#{schedule}", schedule: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/schedules/#{id}")

      assert %{
               "id" => ^id,
               "consecutive_night_count" => 43,
               "end_date" => "2025-10-07",
               "start_date" => "2025-10-07"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, schedule: schedule} do
      conn = put(conn, ~p"/api/schedules/#{schedule}", schedule: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete schedule" do
    setup [:create_schedule]

    test "deletes chosen schedule", %{conn: conn, schedule: schedule} do
      conn = delete(conn, ~p"/api/schedules/#{schedule}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/schedules/#{schedule}")
      end
    end
  end

  defp create_schedule(_) do
    schedule = schedule_fixture()

    %{schedule: schedule}
  end
end
