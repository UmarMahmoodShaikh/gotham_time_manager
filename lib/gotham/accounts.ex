defmodule Gotham.Accounts do
  @moduledoc """
  The Accounts context: managing users, roles, and permissions.
  """

  import Ecto.Query, warn: false
  alias Gotham.Accounts.User
  alias Gotham.Repo

  alias Gotham.Accounts.{User, Role, Permission}

  # ------------------------
  # User Functions
  # ------------------------
  def list_users, do: Repo.all(User)
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Fetch a user by id.

  Returns `{:ok, %User{}}` when found, or `{:error, :not_found}` when no user exists.
  """
  def get_user(id) do
    case Repo.get(User, id) do
      %User{} = user -> {:ok, user}
      nil -> {:error, :not_found}
    end
  end

  def create_user(attrs) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  def delete_user(%User{} = user), do: Repo.delete(user)
  def change_user(%User{} = user, attrs \\ %{}), do: User.changeset(user, attrs)

  # ------------------------
  # Role Functions
  # ------------------------
  def list_roles, do: Repo.all(Role)
  def get_role!(id), do: Repo.get!(Role, id)

  def create_role(attrs) do
    %Role{}
    |> Role.changeset(attrs)
    |> Repo.insert()
  end

  def update_role(%Role{} = role, attrs) do
    role
    |> Role.changeset(attrs)
    |> Repo.update()
  end

  def delete_role(%Role{} = role), do: Repo.delete(role)
  def change_role(%Role{} = role, attrs \\ %{}), do: Role.changeset(role, attrs)

  # ------------------------
  # Permission Functions
  # ------------------------
  def list_permissions, do: Repo.all(Permission)
  def get_permission!(id), do: Repo.get!(Permission, id)

  def create_permission(attrs) do
    %Permission{}
    |> Permission.changeset(attrs)
    |> Repo.insert()
  end

  def update_permission(%Permission{} = permission, attrs) do
    permission
    |> Permission.changeset(attrs)
    |> Repo.update()
  end

  def delete_permission(%Permission{} = permission), do: Repo.delete(permission)

  def change_permission(%Permission{} = permission, attrs \\ %{}),
    do: Permission.changeset(permission, attrs)

  # Sign a JWT for a user
  def generate_token(%User{id: id}) do
    {:ok, token, _claims} = Gotham.Token.generate_and_sign(%{"user_id" => id})
    token
  end

  # Verify a token
  def verify_token(token) do
    case Gotham.Token.verify_and_validate(token) do
      {:ok, %{"user_id" => user_id}} -> {:ok, user_id}
      {:error, _} -> {:error, :invalid_token}
    end
  end

  # Authenticate user by email/password
  def authenticate_user(email, password) do
    case Repo.get_by(User, email: email) do
      nil ->
        {:error, :not_found}

      user ->
        if Bcrypt.verify_pass(password, user.password_hash) do
          {:ok, user}
        else
          {:error, :unauthorized}
        end
    end
  end

  alias Gotham.Repo
  alias Gotham.Accounts.Permission

  #  def update_permission_for_user(manager_id, managed_user_id, attrs) do
  #    case Repo.get_by(Permission, manager_id: manager_id, managed_user_id: managed_user_id) do
  #      nil ->
  #        %Permission{manager_id: manager_id, managed_user_id: managed_user_id}
  #        |> Permission.changeset(attrs)
  #        |> Repo.insert()
  #      permission ->
  #        permission
  #        |> Permission.changeset(attrs)
  #        |> Repo.update()
  #    end
  #  end
  def update_permission_for_user(manager_id, managed_user_id, attrs) do
    case Repo.get_by(Permission, manager_id: manager_id, managed_user_id: managed_user_id) do
      nil ->
        %Permission{}
        |> Permission.changeset(attrs)
        |> Repo.insert()

      permission ->
        permission
        |> Permission.changeset(attrs)
        |> Repo.update()
    end
  end

  def revoke_permission(manager_id, managed_user_id) do
    case Repo.get_by(Permission, manager_id: manager_id, managed_user_id: managed_user_id) do
      nil ->
        {:error, :not_found}

      permission ->
        Repo.delete(permission)
    end
  end
end
