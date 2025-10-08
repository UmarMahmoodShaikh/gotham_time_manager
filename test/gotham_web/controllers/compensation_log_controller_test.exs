defmodule GothamWeb.CompensationLogControllerTest do
  use GothamWeb.ConnCase

  import Gotham.PayrollFixtures
  alias Gotham.Payroll.CompensationLog

  @create_attrs %{
    pay_rate_type: "some pay_rate_type",
    hours_calculated: "120.5"
  }
  @update_attrs %{
    pay_rate_type: "some updated pay_rate_type",
    hours_calculated: "456.7"
  }
  @invalid_attrs %{pay_rate_type: nil, hours_calculated: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all compensation_logs", %{conn: conn} do
      conn = get(conn, ~p"/api/compensation_logs")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create compensation_log" do
    test "renders compensation_log when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/compensation_logs", compensation_log: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/compensation_logs/#{id}")

      assert %{
               "id" => ^id,
               "hours_calculated" => "120.5",
               "pay_rate_type" => "some pay_rate_type"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/compensation_logs", compensation_log: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update compensation_log" do
    setup [:create_compensation_log]

    test "renders compensation_log when data is valid", %{
      conn: conn,
      compensation_log: %CompensationLog{id: id} = compensation_log
    } do
      conn =
        put(conn, ~p"/api/compensation_logs/#{compensation_log}", compensation_log: @update_attrs)

      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/compensation_logs/#{id}")

      assert %{
               "id" => ^id,
               "hours_calculated" => "456.7",
               "pay_rate_type" => "some updated pay_rate_type"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, compensation_log: compensation_log} do
      conn =
        put(conn, ~p"/api/compensation_logs/#{compensation_log}",
          compensation_log: @invalid_attrs
        )

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete compensation_log" do
    setup [:create_compensation_log]

    test "deletes chosen compensation_log", %{conn: conn, compensation_log: compensation_log} do
      conn = delete(conn, ~p"/api/compensation_logs/#{compensation_log}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/compensation_logs/#{compensation_log}")
      end
    end
  end

  defp create_compensation_log(_) do
    compensation_log = compensation_log_fixture()

    %{compensation_log: compensation_log}
  end
end
