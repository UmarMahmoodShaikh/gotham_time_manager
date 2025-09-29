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

   def login(conn, %{"email" => email, "password" => password}) do
    case Accounts.authenticate_user(email, password) do
      {:ok, user} ->
        # You can generate a token here if you use JWT or similar
        render(conn, :show, user: user)
      {:error, :unauthorized} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Invalid email or password"})
    end
  end

  def login(conn, _params) do
    conn
    |> put_status(:bad_request)
    |> json(%{error: "Missing email or password"})
  end
end
