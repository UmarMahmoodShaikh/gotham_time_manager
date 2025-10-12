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
    field :work_location, :string
    field :latitude, :decimal
    field :longitude, :decimal
    field :total_hours, :decimal
    field :status, :string, default: "pending"
    field :is_manual, :boolean, default: false
    field :justification, :string
    field :notes, :string
    field :approved_at, :utc_datetime
    field :rejection_reason, :string

    belongs_to :user, Gotham.Accounts.User
    belongs_to :approved_by, Gotham.Accounts.User

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
      :user_id,
      :work_location,
      :latitude,
      :longitude,
      :total_hours,
      :status,
      :is_manual,
      :justification,
      :notes,
      :approved_by_id,
      :approved_at,
      :rejection_reason
    ])
    |> validate_required([:start_time, :user_id])
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:approved_by_id)
  end

  def clock_in_changeset(working_time, attrs) do
    working_time
    |> cast(attrs, [
      :start_time,
      :user_id,
      :work_location,
      :latitude,
      :longitude,
      :notes
    ])
    |> validate_required([:start_time, :user_id])
    |> put_change(:status, "in_progress")
    |> foreign_key_constraint(:user_id)
  end

  def clock_out_changeset(working_time, attrs) do
    working_time
    |> cast(attrs, [
      :end_time,
      :notes,
      :latitude,
      :longitude
    ])
    |> validate_required([:end_time])
    |> put_change(:status, "completed")
    |> calculate_total_hours()
  end

  def manual_entry_changeset(working_time, attrs) do
    working_time
    |> cast(attrs, [
      :start_time,
      :end_time,
      :user_id,
      :work_location,
      :justification,
      :notes
    ])
    |> validate_required([:start_time, :end_time, :user_id, :justification])
    |> put_change(:is_manual, true)
    |> put_change(:is_manual_entry, true)
    |> put_change(:status, "pending")
    |> calculate_total_hours()
    |> foreign_key_constraint(:user_id)
  end

  defp calculate_total_hours(changeset) do
    case {get_field(changeset, :start_time), get_field(changeset, :end_time)} do
      {start_time, end_time} when not is_nil(start_time) and not is_nil(end_time) ->
        total_hours = DateTime.diff(end_time, start_time) / 3600
        put_change(changeset, :total_hours, Decimal.from_float(total_hours))
      _ ->
        changeset
    end
  end
end
