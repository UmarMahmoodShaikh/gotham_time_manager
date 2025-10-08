defmodule Gotham.TimeTracking.WorkingTime do
  use Ecto.Schema
  import Ecto.Changeset

  schema "working_times" do
    field :start_time, :utc_datetime
    field :end_time, :utc_datetime
    field :is_manual_entry, :boolean, default: false
    field :validation_status, :string
    field :unpaid_overtime_hours, :decimal
    field :is_transition_time, :boolean, default: false
    field :user_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(working_time, attrs) do
    working_time
    |> cast(attrs, [
      :start_time,
      :end_time,
      :is_manual_entry,
      :validation_status,
      :unpaid_overtime_hours,
      :is_transition_time,
      :user_id
    ])
    |> validate_required([:start_time, :user_id])
  end
end
