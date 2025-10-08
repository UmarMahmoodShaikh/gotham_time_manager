defmodule GothamWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use GothamWeb, :controller

  @jsonapi "application/vnd.api+json"

  # Resource not found
  def call(conn, {:error, :not_found}) do
    conn
    |> put_resp_content_type(@jsonapi)
    |> put_status(:not_found)
    |> json(%{errors: [%{status: "404", title: "Not Found"}]})
  end

  # Validation errors
  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    errors =
      Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
        Enum.reduce(opts, msg, fn {key, value}, acc ->
          String.replace(acc, "%{#{key}}", to_string(value))
        end)
      end)

    conn
    |> put_resp_content_type(@jsonapi)
    |> put_status(:unprocessable_entity)
    |> json(%{errors: [%{status: "422", title: "Validation failed", detail: errors}]})
  end

  # Unauthorized
  def call(conn, {:error, :unauthorized}) do
    conn
    |> put_resp_content_type(@jsonapi)
    |> put_status(:unauthorized)
    |> json(%{errors: [%{status: "401", title: "Unauthorized"}]})
  end

  # Generic fallback
  def call(conn, _) do
    conn
    |> put_resp_content_type(@jsonapi)
    |> put_status(:bad_request)
    |> json(%{errors: [%{status: "400", title: "Bad Request"}]})
  end
end
