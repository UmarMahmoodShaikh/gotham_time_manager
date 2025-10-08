defmodule Gotham.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Gotham.Accounts` context.
  """

  @doc """
  Generate a unique user email.
  """
  def unique_user_email, do: "some email#{System.unique_integer([:positive])}"

  @doc """
  Generate a user.
  """
  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        email: unique_user_email(),
        first_name: "some first_name",
        is_visually_challenged: true,
        last_name: "some last_name",
        password_hash: "some password_hash",
        username: "some username"
      })
      |> Gotham.Accounts.create_user()

    user
  end

  @doc """
  Generate a role.
  """
  def role_fixture(attrs \\ %{}) do
    {:ok, role} =
      attrs
      |> Enum.into(%{
        label: "some label"
      })
      |> Gotham.Accounts.create_role()

    role
  end

  @doc """
  Generate a permission.
  """
  def permission_fixture(attrs \\ %{}) do
    {:ok, permission} =
      attrs
      |> Enum.into(%{
        permission_level: "some permission_level"
      })
      |> Gotham.Accounts.create_permission()

    permission
  end
end
