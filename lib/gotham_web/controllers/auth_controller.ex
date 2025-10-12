defmodule GothamWeb.AuthController do
  use GothamWeb, :controller
  alias Gotham.Accounts
  alias Gotham.Accounts.Role
  alias Gotham.Repo

  @jsonapi "application/vnd.api+json"

  def sign_up(conn, params) do
    with %{
           "email" => email,
           "password" => password,
           "personal_email" => personal_email,
           "username" => username,
           "first_name" => first_name,
           "last_name" => last_name,
           "is_visually_challenged" => is_visually_challenged
         } <- params,
         {:ok, user} <-
           Accounts.create_user(%{
             email: email,
             password: password,
             personal_email: personal_email,
             username: username,
             first_name: first_name,
             last_name: last_name,
             is_visually_challenged: is_visually_challenged
           }),
         token <- Accounts.generate_token(user) do
      conn
      |> put_resp_content_type(@jsonapi)
      |> put_status(:created)
      |> json(%{
        data: %{
          type: "users",
          id: user.id,
          attributes: %{
            email: user.email,
            username: user.username,
            first_name: user.first_name,
            last_name: user.last_name,
            is_visually_challenged: user.is_visually_challenged,
            role_id: user.role_id,
            role: Repo.get(Role, user.role_id).label
          }
        },
        meta: %{token: token}
      })
    else
      {:error, changeset} ->
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

      _ ->
        conn
        |> put_resp_content_type(@jsonapi)
        |> put_status(:bad_request)
        |> json(%{errors: [%{status: "400", title: "Bad Request"}]})
    end
  end

  def sign_in(conn, %{"email" => email, "password" => password}) do
    case Accounts.authenticate_user(email, password) do
      {:ok, user} ->
        token = Accounts.generate_token(user)
        # Generate a Base64-encoded CSRF token
        csrf_token = Base.encode64(:crypto.strong_rand_bytes(32))

        conn
        |> put_resp_content_type(@jsonapi)
        |> put_resp_header("x-xsrf-token", csrf_token)
        |> json(%{
          data: %{
            type: "users",
            id: user.id,
            attributes: %{
              email: user.email,
              username: user.username,
              first_name: user.first_name,
              last_name: user.last_name,
              is_visually_challenged: user.is_visually_challenged,
              role_id: user.role_id,
              role: Repo.get(Role, user.role_id).label
            }
          },
          meta: %{
            token: token,
            csrf_token: csrf_token
          }
        })

      {:error, :not_found} ->
        conn
        |> put_resp_content_type(@jsonapi)
        |> put_status(:unauthorized)
        |> json(%{errors: [%{status: "421", title: "Invalid Credentials"}]})

      {:error, :unauthorized} ->
        conn
        |> put_resp_content_type(@jsonapi)
        |> put_status(:unauthorized)
        |> json(%{errors: [%{status: "421", title: "Invalid Credentials"}]})
    end
  end

  # For stateless JWT, sign_out is a no-op; client discards token
  def sign_out(conn, _params) do
    conn
    |> put_resp_content_type(@jsonapi)
    |> send_resp(:no_content, "")
  end

  # Login endpoint compatible with API documentation
  def login(conn, %{"password" => password} = params) do
    identifier =
      cond do
        Map.has_key?(params, "email") -> {:email, params["email"]}
        Map.has_key?(params, "username") -> {:username, params["username"]}
        true -> nil
      end

    case identifier do
      {:email, email} ->
        do_login(conn, email, password)

      {:username, username} ->
        do_login_by_username(conn, username, password)

      nil ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "Missing email or username"})
    end
  end

  # Logout endpoint compatible with API documentation
  def logout(conn, _params) do
    conn
    |> put_status(:ok)
    |> json(%{message: "Logged out successfully"})
  end

  # Helper function for email-based login
  defp do_login(conn, email, password) do
    case Accounts.authenticate_user(email, password) do
      {:ok, user} ->
        conn
        |> put_status(:ok)
        |> json(%{
          status: "ok",
          user_id: user.id,
          email: user.email,
          role: Repo.get(Role, user.role_id).label
        })

      {:error, :not_found} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Invalid credentials"})

      {:error, :unauthorized} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Invalid credentials"})
    end
  end

  # Helper function for username-based login
  defp do_login_by_username(conn, username, password) do
    # First, find the user by username to get their email
    case Repo.get_by(Gotham.Accounts.User, username: username) do
      nil ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Invalid credentials"})

      user ->
        # Use the email with the existing authenticate_user function
        case Accounts.authenticate_user(user.email, password) do
          {:ok, user} ->
            conn
            |> put_status(:ok)
            |> json(%{
              status: "ok",
              user_id: user.id,
              email: user.email,
              role: Repo.get(Role, user.role_id).label
            })

          {:error, :unauthorized} ->
            conn
            |> put_status(:unauthorized)
            |> json(%{error: "Invalid credentials"})
        end
    end
  end

  # JWT-based auth endpoints for Postman collection compatibility

  # POST /api/auth/register
  def register(conn, params) do
    with %{
           "email" => email,
           "password" => password,
           "first_name" => first_name,
           "last_name" => last_name
         } <- params,
         role_id <- Map.get(params, "role_id", 1),
         username <- Map.get(params, "username", email),
         personal_email <- Map.get(params, "personal_email", email),
         {:ok, user} <-
           Accounts.create_user(%{
             email: email,
             password: password,
             personal_email: personal_email,
             username: username,
             first_name: first_name,
             last_name: last_name,
             role_id: role_id,
             is_visually_challenged: Map.get(params, "is_visually_challenged", false)
           }),
         token <- Accounts.generate_token(user) do
      conn
      |> put_status(:created)
      |> json(%{
        message: "User registered successfully",
        data: %{
          id: user.id,
          email: user.email,
          first_name: user.first_name,
          last_name: user.last_name,
          username: user.username,
          role_id: user.role_id,
          token: token
        }
      })
    else
      {:error, changeset} ->
        errors =
          Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
            Enum.reduce(opts, msg, fn {key, value}, acc ->
              String.replace(acc, "%{#{key}}", to_string(value))
            end)
          end)

        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: "Registration failed", details: errors})

      _ ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "Missing required fields"})
    end
  end

  # POST /api/auth/login
  def auth_login(conn, %{"email" => email, "password" => password}) do
    case Accounts.authenticate_user(email, password) do
      {:ok, user} ->
        token = Accounts.generate_token(user)
        csrf_token = Base.encode64(:crypto.strong_rand_bytes(32))

        conn
        |> put_resp_header("x-xsrf-token", csrf_token)
        |> put_status(:ok)
        |> json(%{
          message: "Login successful",
          data: %{
            user: %{
              id: user.id,
              email: user.email,
              first_name: user.first_name,
              last_name: user.last_name,
              username: user.username,
              role_id: user.role_id,
              role: Repo.get(Role, user.role_id).label
            },
            token: token,
            csrf_token: csrf_token
          }
        })

      {:error, _} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Invalid credentials"})
    end
  end

  # POST /api/auth/logout
  def auth_logout(conn, _params) do
    conn
    |> put_status(:ok)
    |> json(%{message: "Logged out successfully"})
  end

  # GET /api/auth/me (requires auth pipeline)
  def me(conn, _params) do
    current_user = conn.assigns.current_user

    conn
    |> put_status(:ok)
    |> json(%{
      data: %{
        id: current_user.id,
        email: current_user.email,
        first_name: current_user.first_name,
        last_name: current_user.last_name,
        username: current_user.username,
        role_id: current_user.role_id,
        role: Repo.get(Role, current_user.role_id).label
      }
    })
  end
end
