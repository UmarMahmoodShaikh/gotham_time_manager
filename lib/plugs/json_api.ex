defmodule GothamWeb.Plugs.JsonApi do
  @moduledoc """
  Ensures requests/responses follow JSON:API conventions by
  - refusing non-JSON requests in API scope
  - setting the `application/vnd.api+json` content type on responses
  """

  import Plug.Conn

  @jsonapi "application/vnd.api+json"

  def init(opts), do: opts

  def call(%Plug.Conn{req_headers: headers} = conn, _opts) do
    accepts_json? =
      Enum.any?(headers, fn {k, v} ->
        (k == "accept" and String.contains?(v, @jsonapi)) or
          String.contains?(v, "application/json")
      end)

    conn = put_resp_content_type(conn, @jsonapi)

    if accepts_json? do
      conn
    else
      conn
      |> send_resp(406, Jason.encode!(%{errors: [%{status: "406", title: "Not Acceptable"}]}))
      |> halt()
    end
  end
end
