defmodule GothamWeb.AuthController do
  use GothamWeb, :controller
  alias Gotham.Accounts

  @jsonapi "application/vnd.api+json"

  def sign_up(conn, params) do
    with %{
           "email" => email,
           "password" => password,
           "username" => username,
           "first_name" => first_name,
           "last_name" => last_name,
           "is_visually_challenged" => is_visually_challenged
         } <- params,
         {:ok, user} <-
           Accounts.create_user(%{
             email: email,
             password: password,
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
            is_visually_challenged: user.is_visually_challenged
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
              is_visually_challenged: user.is_visually_challenged
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
end
