defmodule GothamWeb.TaskSkillControllerTest do
  use GothamWeb.ConnCase

  import Gotham.ActivitiesFixtures
  alias Gotham.Activities.TaskSkill

  @create_attrs %{
    note: "some note"
  }
  @update_attrs %{
    note: "some updated note"
  }
  @invalid_attrs %{note: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all task_skills", %{conn: conn} do
      conn = get(conn, ~p"/api/task_skills")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create task_skill" do
    test "renders task_skill when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/task_skills", task_skill: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/task_skills/#{id}")

      assert %{
               "id" => ^id,
               "note" => "some note"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/task_skills", task_skill: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update task_skill" do
    setup [:create_task_skill]

    test "renders task_skill when data is valid", %{
      conn: conn,
      task_skill: %TaskSkill{id: id} = task_skill
    } do
      conn = put(conn, ~p"/api/task_skills/#{task_skill}", task_skill: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/task_skills/#{id}")

      assert %{
               "id" => ^id,
               "note" => "some updated note"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, task_skill: task_skill} do
      conn = put(conn, ~p"/api/task_skills/#{task_skill}", task_skill: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete task_skill" do
    setup [:create_task_skill]

    test "deletes chosen task_skill", %{conn: conn, task_skill: task_skill} do
      conn = delete(conn, ~p"/api/task_skills/#{task_skill}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/task_skills/#{task_skill}")
      end
    end
  end

  defp create_task_skill(_) do
    task_skill = task_skill_fixture()

    %{task_skill: task_skill}
  end
end
