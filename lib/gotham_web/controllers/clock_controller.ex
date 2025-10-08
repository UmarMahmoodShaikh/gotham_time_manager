defmodule GothamWeb.ClockController do
  use GothamWeb, :controller

  alias Gotham.TimeTracking
  alias Gotham.TimeTracking.Clock

  action_fallback GothamWeb.FallbackController

  def show(conn, %{"userID" => user_id}) do
    user_id = normalize_id(user_id)
    clocks = TimeTracking.list_user_clocks(user_id)
    render(conn, :index, clocks: clocks)
  end

  def create(conn, %{"userID" => user_id} = params) do
    user_id = normalize_id(user_id)
    attrs = Map.get(params, "clock", %{})

    with {:ok, %Clock{} = _clock} <- TimeTracking.toggle_clock!(user_id, attrs) do
      clocks = TimeTracking.list_user_clocks(user_id)
      render(conn, :index, clocks: clocks)
    end
  end

  # Router exposes:
  #   get "/audit/presence_verification", ClockController, :presence_verification
  def presence_verification(conn, _params) do
    conn
    |> put_status(:not_implemented)
    |> json(%{errors: [%{status: "501", title: "Not Implemented"}]})
  end

  defp normalize_id(id) when is_integer(id), do: id

  defp normalize_id(id) when is_binary(id) do
    case Integer.parse(id) do
      {int, _} -> int
      :error -> id
    end
  end
end
