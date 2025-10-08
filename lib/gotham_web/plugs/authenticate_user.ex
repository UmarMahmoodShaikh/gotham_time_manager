defmodule GothamWeb.Plugs.AuthenticateUser do
  import Plug.Conn
  import Phoenix.Controller
  require Logger

  def init(opts), do: opts

  def call(conn, _opts) do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
         {:ok, user_id} <- Gotham.Accounts.verify_token(token),
         user when not is_nil(user) <- Gotham.Accounts.get_user!(user_id) do
      conn
      |> assign(:current_user, user)
    else
      [] ->
        Logger.debug("Missing Authorization header")
        send_unauthorized(conn, "Missing headers")

      nil ->
        Logger.debug("User not found")
        send_unauthorized(conn, "User not found")

      {:error, reason} ->
        Logger.debug("Token verification failed: #{inspect(reason)}")
        send_unauthorized(conn, "Sorry! Your Session is expired")

      error ->
        Logger.debug("Authentication failed: #{inspect(error)}")
        send_unauthorized(conn, "Authentication failed")
    end
  end

  defp send_unauthorized(conn, message) do
    conn
    |> put_status(:unauthorized)
    |> json(%{errors: %{detail: message}})
    |> halt()
  end
end
