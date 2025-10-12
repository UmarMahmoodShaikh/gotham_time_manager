defmodule Gotham.TimeTracking.Break do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :integer

  schema "breaks" do
    field :break_type, :string, default: "regular" # regular, lunch, emergency
    field :start_time, :utc_datetime
    field :end_time, :utc_datetime
    field :duration_minutes, :integer
    field :status, :string, default: "active" # active, completed, cancelled
    field :notes, :string

    belongs_to :user, Gotham.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(break_entry, attrs) do
    break_entry
    |> cast(attrs, [:user_id, :break_type, :start_time, :end_time, :duration_minutes, :status, :notes])
    |> validate_required([:user_id, :break_type, :start_time, :status])
    |> validate_inclusion(:break_type, ["regular", "lunch", "emergency"])
    |> validate_inclusion(:status, ["active", "completed", "cancelled"])
    |> foreign_key_constraint(:user_id)
  end
end
