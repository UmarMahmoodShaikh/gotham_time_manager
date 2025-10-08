defmodule GothamWeb.SkillControllerTest do
  use GothamWeb.ConnCase

  import Gotham.ActivitiesFixtures
  alias Gotham.Activities.Skill

  @create_attrs %{
    label: "some label"
  }
  @update_attrs %{
    label: "some updated label"
  }
  @invalid_attrs %{label: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all skills", %{conn: conn} do
      conn = get(conn, ~p"/api/skills")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create skill" do
    test "renders skill when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/skills", skill: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/skills/#{id}")

      assert %{
               "id" => ^id,
               "label" => "some label"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/skills", skill: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update skill" do
    setup [:create_skill]

    test "renders skill when data is valid", %{conn: conn, skill: %Skill{id: id} = skill} do
      conn = put(conn, ~p"/api/skills/#{skill}", skill: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/skills/#{id}")

      assert %{
               "id" => ^id,
               "label" => "some updated label"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, skill: skill} do
      conn = put(conn, ~p"/api/skills/#{skill}", skill: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete skill" do
    setup [:create_skill]

    test "deletes chosen skill", %{conn: conn, skill: skill} do
      conn = delete(conn, ~p"/api/skills/#{skill}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/skills/#{skill}")
      end
    end
  end

  defp create_skill(_) do
    skill = skill_fixture()

    %{skill: skill}
  end
end
