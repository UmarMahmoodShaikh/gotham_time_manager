defmodule GothamWeb.UnrecognizedWorkController do
  use GothamWeb, :controller

  alias Gotham.Activities
  alias Gotham.Activities.UnrecognizedWork

  action_fallback GothamWeb.FallbackController

  def index(conn, _params) do
    unrecognized_works = Activities.list_unrecognized_works()
    render(conn, :index, unrecognized_works: unrecognized_works)
  end

  def create(conn, %{"unrecognized_work" => unrecognized_work_params}) do
    with {:ok, %UnrecognizedWork{} = unrecognized_work} <-
           Activities.create_unrecognized_work(unrecognized_work_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/unrecognized_works/#{unrecognized_work}")
      |> render(:show, unrecognized_work: unrecognized_work)
    end
  end

  def show(conn, %{"id" => id}) do
    unrecognized_work = Activities.get_unrecognized_work!(id)
    render(conn, :show, unrecognized_work: unrecognized_work)
  end

  def update(conn, %{"id" => id, "unrecognized_work" => unrecognized_work_params}) do
    unrecognized_work = Activities.get_unrecognized_work!(id)

    with {:ok, %UnrecognizedWork{} = unrecognized_work} <-
           Activities.update_unrecognized_work(unrecognized_work, unrecognized_work_params) do
      render(conn, :show, unrecognized_work: unrecognized_work)
    end
  end

  def delete(conn, %{"id" => id}) do
    unrecognized_work = Activities.get_unrecognized_work!(id)

    with {:ok, %UnrecognizedWork{}} <- Activities.delete_unrecognized_work(unrecognized_work) do
      send_resp(conn, :no_content, "")
    end
  end
end
