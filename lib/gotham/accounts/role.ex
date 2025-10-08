defmodule Gotham.Accounts.Role do
  use Ecto.Schema
  import Ecto.Changeset

  schema "roles" do
    field :label, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(role, attrs) do
    role
    |> cast(attrs, [:label])
    |> validate_required([:label])
  end

  # Numeric role IDs (enum mapping)
  @admin_id 1
  @manager_id 2
  @hr_id 3
  @employee_id 4

  def admin_id, do: @admin_id
  def manager_id, do: @manager_id
  def hr_id, do: @hr_id
  def employee_id, do: @employee_id
end
