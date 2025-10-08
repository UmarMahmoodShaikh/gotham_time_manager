defmodule GothamWeb.UnrecognizedWorkControllerTest do
  use GothamWeb.ConnCase

  import Gotham.ActivitiesFixtures
  alias Gotham.Activities.UnrecognizedWork

  @create_attrs %{
    description: "some description"
  }
  @update_attrs %{
    description: "some updated description"
  }
  @invalid_attrs %{description: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all unrecognized_works", %{conn: conn} do
      conn = get(conn, ~p"/api/unrecognized_works")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create unrecognized_work" do
    test "renders unrecognized_work when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/unrecognized_works", unrecognized_work: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/unrecognized_works/#{id}")

      assert %{
               "id" => ^id,
               "description" => "some description"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/unrecognized_works", unrecognized_work: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update unrecognized_work" do
    setup [:create_unrecognized_work]

    test "renders unrecognized_work when data is valid", %{
      conn: conn,
      unrecognized_work: %UnrecognizedWork{id: id} = unrecognized_work
    } do
      conn =
        put(conn, ~p"/api/unrecognized_works/#{unrecognized_work}",
          unrecognized_work: @update_attrs
        )

      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/unrecognized_works/#{id}")

      assert %{
               "id" => ^id,
               "description" => "some updated description"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{
      conn: conn,
      unrecognized_work: unrecognized_work
    } do
      conn =
        put(conn, ~p"/api/unrecognized_works/#{unrecognized_work}",
          unrecognized_work: @invalid_attrs
        )

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete unrecognized_work" do
    setup [:create_unrecognized_work]

    test "deletes chosen unrecognized_work", %{conn: conn, unrecognized_work: unrecognized_work} do
      conn = delete(conn, ~p"/api/unrecognized_works/#{unrecognized_work}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/unrecognized_works/#{unrecognized_work}")
      end
    end
  end

  defp create_unrecognized_work(_) do
    unrecognized_work = unrecognized_work_fixture()

    %{unrecognized_work: unrecognized_work}
  end
end
