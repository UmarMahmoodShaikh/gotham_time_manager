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

  def show(conn, %{"id" => id}) do
#    user = Accounts.get_user!(id)
#    render(conn, :show, user: user)
    case Repo.get(User, id) do
      nil ->
        conn
        |> put_status(404)
        |> json(%{message: "User not found"})
      user ->
        render(conn, :show, user: user)
    end
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Accounts.get_user!(id)
    with {:ok, %User{} = user} <- Accounts.update_user(user, user_params) do
      render(conn, :show, user: user)
    end
  end


  def delete(conn, %{"id" => id}) do
#    user = Accounts.get_user!(id)
#
#    with {:ok, %User{}} <- Accounts.delete_user(user) do
#      send_resp(conn, :no_content, "")
#    end
    case Repo.get(User, id) do
      nil ->
        conn
        |> put_status(404)
        |> json(%{message: "User not found"})
      user ->
        with {:ok, %Task{}} <- Accounts.delete_user(user) do
          send_resp(conn, 204, "User Deleted Successfully")
        end
    end
  end

  # def login(conn, %{"email" => email, "username" => username, "password" => password}) do
  #   case Accounts.authenticate_user(email, username, password) do
  #     {:ok, %User{id: id, email: email, role: role}} ->
  #       json(conn, %{
  #         status: "ok",
  #         user_id: id,
  #         email: email,
  #         role: role
  #       })

  #     {:error, :unauthorized} ->
  #       conn
  #       |> put_status(:unauthorized)
  #       |> json(%{error: "Invalid email or password"})
  #   end
  # end

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
      json(conn, %{
        status: "ok",
        user_id: id,
        email: email,
        role: role
      })

    {:error, :unauthorized} ->
      conn
      |> put_status(:unauthorized)
      |> json(%{error: "Invalid credentials"})
  end
end
end
