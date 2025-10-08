defmodule GothamWeb.TaskAssignmentControllerTest do
  use GothamWeb.ConnCase

  import Gotham.ActivitiesFixtures
  alias Gotham.Activities.TaskAssignment

  @create_attrs %{
    notes: "some notes"
  }
  @update_attrs %{
    notes: "some updated notes"
  }
  @invalid_attrs %{notes: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all task_assignments", %{conn: conn} do
      conn = get(conn, ~p"/api/task_assignments")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create task_assignment" do
    test "renders task_assignment when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/task_assignments", task_assignment: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/task_assignments/#{id}")

      assert %{
               "id" => ^id,
               "notes" => "some notes"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/task_assignments", task_assignment: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update task_assignment" do
    setup [:create_task_assignment]

    test "renders task_assignment when data is valid", %{
      conn: conn,
      task_assignment: %TaskAssignment{id: id} = task_assignment
    } do
      conn =
        put(conn, ~p"/api/task_assignments/#{task_assignment}", task_assignment: @update_attrs)

      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/task_assignments/#{id}")

      assert %{
               "id" => ^id,
               "notes" => "some updated notes"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, task_assignment: task_assignment} do
      conn =
        put(conn, ~p"/api/task_assignments/#{task_assignment}", task_assignment: @invalid_attrs)

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete task_assignment" do
    setup [:create_task_assignment]

    test "deletes chosen task_assignment", %{conn: conn, task_assignment: task_assignment} do
      conn = delete(conn, ~p"/api/task_assignments/#{task_assignment}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/task_assignments/#{task_assignment}")
      end
    end
  end

  defp create_task_assignment(_) do
    task_assignment = task_assignment_fixture()

    %{task_assignment: task_assignment}
  end
end
