defmodule GothamTimeManagerWeb.UserController do
  use GothamTimeManagerWeb, :controller
  alias GothamTimeManager.Repo
  alias GothamTimeManager.Accounts
  alias GothamTimeManager.Accounts.User

  action_fallback GothamTimeManagerWeb.FallbackController

  def index(conn, _params) do
    users = Accounts.list_users()
    render(conn, :index, users: users)
  end

  def create(conn, %{"user" => user_params}) do
    with {:ok, %User{} = user} <- Accounts.create_user(user_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/users/#{user}")
      |> render(:show, user: user)
    end
  end

  def show(conn, params) do
    identifier =
      cond do
        Map.has_key?(params, "email") -> {:email, params["email"]}
        Map.has_key?(params, "username") -> {:username, params["username"]}
        Map.has_key?(params, "id") -> {:id, params["id"]}
        true -> nil
      end

    case identifier do
      {:email, email} -> fetch_and_render_user(conn, Repo.get_by(User, email: email))
      {:username, username} -> fetch_and_render_user(conn, Repo.get_by(User, username: username))
      {:id, id} -> fetch_and_render_user(conn, Repo.get(User, id))
      nil ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "Provide email, username, or id"})
    end
  end

  defp fetch_and_render_user(conn, nil) do
    conn
    |> put_status(404)
    |> json(%{message: "User not found"})
  end

  defp fetch_and_render_user(conn, user) do
    render(conn, :show, user: user)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Accounts.get_user!(id)
    with {:ok, %User{} = user} <- Accounts.update_user(user, user_params) do
      render(conn, :show, user: user)
    end
  end

  def delete(conn, %{"email" => email}) do
    case Repo.get_by(User, email: email) do
      nil ->
        conn
        |> put_status(404)
        |> json(%{message: "User not found"})
      user ->
        with {:ok, %User{}} <- Accounts.delete_user(user) do
          send_resp(conn, :no_content, "")
        end
    end
  end

  def login(conn, %{"password" => password} = params) do
    identifier =
      cond do
        Map.has_key?(params, "email") -> {:email, params["email"]}
        Map.has_key?(params, "username") -> {:username, params["username"]}
        true -> nil
      end

    case identifier do
      {:email, email} ->
        do_login(conn, email, nil, password)

      {:username, username} ->
        do_login(conn, nil, username, password)

      nil ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "Missing email or username"})
    end
  end

  defp do_login(conn, email, username, password) do
    case Accounts.authenticate_user(email, username, password) do
      {:ok, %User{id: id, email: email, role: role}} ->
        jwt = sign_jwt(id)
        xsrf = generate_xsrf()

        conn
        |> put_session(:xsrf_token, xsrf)
        |> put_resp_cookie("XSRF-TOKEN", xsrf, http_only: false, same_site: "Lax")
        |> json(%{
          status: "ok",
          user_id: id,
          email: email,
          role: role,
          token: jwt,
          xsrf_token: xsrf
        })

      {:error, :unauthorized} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Invalid credentials"})
    end
  end

  defp sign_jwt(user_id) do
    case GothamTimeManager.Token.generate_for_user(user_id) do
      {:ok, token} -> token
      {:error, reason} -> raise "JWT generation failed: #{inspect(reason)}"
    end
  end

  defp generate_xsrf do
    :crypto.strong_rand_bytes(32) |> Base.url_encode64(padding: false)
  end
end
