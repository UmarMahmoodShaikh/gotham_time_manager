defmodule GothamWeb.UserJSON do
  alias Gotham.Accounts.User

  @doc """
  Renders a list of users.
  """
  def index(%{users: users}) do
    %{data: for(user <- users, do: data(user))}
  end

  @doc """
  Renders a single user.
  """
  def show(%{user: user}) do
    %{data: data(user)}
  end

  defp data(%User{} = user) do
    %{
      id: user.id,
      username: user.username,
      email: user.email,
      role:
        (Ecto.assoc_loaded?(user.role) and user.role && user.role.label) ||
          nil,
      first_name: user.first_name,
      last_name: user.last_name,
      is_visually_challenged: user.is_visually_challenged
    }
  end
end
