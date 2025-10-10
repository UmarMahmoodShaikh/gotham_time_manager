defmodule Gotham.Scheduling.Schedule do
  use Ecto.Schema
  import Ecto.Changeset
  alias Gotham.Scheduling.Shift
  alias Gotham.Accounts.User

  schema "schedules" do
    field :date, :date
    field :consecutive_night_count, :integer
    field :user_id, :id
    field :shift_id, :id

    belongs_to :shift, Shift, define_field: false, foreign_key: :shift_id, type: :id
    belongs_to :user, User, define_field: false, foreign_key: :user_id, type: :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(schedule, attrs) do
    schedule
    |> cast(attrs, [:date, :consecutive_night_count, :user_id, :shift_id])
    |> validate_required([:date, :user_id])
    |> assoc_constraint(:shift)
    |> assoc_constraint(:user)
  end
end
