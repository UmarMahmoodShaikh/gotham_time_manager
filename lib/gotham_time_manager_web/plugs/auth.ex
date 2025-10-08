defmodule GothamTimeManagerWeb.Plugs.Auth do
  import Plug.Conn
  alias GothamTimeManager.Repo
  alias GothamTimeManager.Accounts.User
  @behaviour Plug

  def init(opts), do: opts

  def call(conn, _opts) do
    # 1) Authorization header present?
    case get_req_header(conn, "authorization") do
      ["Bearer " <> token] ->
        with {:ok, claims} <- verify_jwt(token),
             %{"sub" => user_id} <- claims,
             user when not is_nil(user) <- Repo.get(User, user_id) do
          # 2) XSRF header must match the session token
          if valid_xsrf?(conn) do
            assign(conn, :current_user, user)
          else
            unauthorized(conn, "missing_or_invalid_xsrf_token")
          end
        else
          {:error, :invalid} -> unauthorized(conn, "invalid_jwt")
          %{} -> unauthorized(conn, "invalid_claims")
          nil -> unauthorized(conn, "user_not_found")
          _ -> unauthorized(conn, "unauthorized")
        end

      _ ->
        unauthorized(conn, "missing_authorization_header")
    end
  end

  defp unauthorized(conn, reason) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(401, Jason.encode!(%{error: "Unauthorized", reason: reason}))
    |> halt()
  end

  defp verify_jwt(token) do
    case GothamTimeManager.Token.verify_token(token) do
      {:ok, claims} when is_map(claims) -> {:ok, claims}
      {:error, _} -> {:error, :invalid}
    end
  end

  defp valid_xsrf?(conn) do
    case {get_req_header(conn, "x-xsrf-token"), get_session(conn, :xsrf_token)} do
      {[header_token], session_token} when is_binary(session_token) -> header_token == session_token
      _ -> false
    end
  end
end
