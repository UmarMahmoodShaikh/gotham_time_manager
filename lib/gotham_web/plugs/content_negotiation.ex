defmodule GothamWeb.Plugs.ContentNegotiation do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    case get_req_header(conn, "accept") do
      ["*/*"] ->
        conn

      ["application/json"] ->
        conn

      ["application/vnd.api+json"] ->
        conn

      # No Accept header should be allowed
      [] ->
        conn

      _ ->
        conn
        |> put_status(:not_acceptable)
        |> Phoenix.Controller.json(%{errors: [%{status: "406", title: "Not Acceptable"}]})
        |> halt()
    end
  end
end
