defmodule GothamWeb.UserSkillControllerTest do
  use GothamWeb.ConnCase

  import Gotham.ActivitiesFixtures
  alias Gotham.Activities.UserSkill

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
    test "lists all user_skills", %{conn: conn} do
      conn = get(conn, ~p"/api/user_skills")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create user_skill" do
    test "renders user_skill when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/user_skills", user_skill: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/user_skills/#{id}")

      assert %{
               "id" => ^id,
               "note" => "some note"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/user_skills", user_skill: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update user_skill" do
    setup [:create_user_skill]

    test "renders user_skill when data is valid", %{
      conn: conn,
      user_skill: %UserSkill{id: id} = user_skill
    } do
      conn = put(conn, ~p"/api/user_skills/#{user_skill}", user_skill: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/user_skills/#{id}")

      assert %{
               "id" => ^id,
               "note" => "some updated note"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, user_skill: user_skill} do
      conn = put(conn, ~p"/api/user_skills/#{user_skill}", user_skill: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete user_skill" do
    setup [:create_user_skill]

    test "deletes chosen user_skill", %{conn: conn, user_skill: user_skill} do
      conn = delete(conn, ~p"/api/user_skills/#{user_skill}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/user_skills/#{user_skill}")
      end
    end
  end

  defp create_user_skill(_) do
    user_skill = user_skill_fixture()

    %{user_skill: user_skill}
  end
end
