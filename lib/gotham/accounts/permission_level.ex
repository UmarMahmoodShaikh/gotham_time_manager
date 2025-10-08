defmodule Gotham.Accounts.PermissionLevel do
  @moduledoc """
  Valid permission levels.
  """

  @levels ["readonly", "write", "create", "delete", "full_access"]

  def levels, do: @levels

  def valid?(level) when is_binary(level), do: level in @levels
  def valid?(_), do: false
end
