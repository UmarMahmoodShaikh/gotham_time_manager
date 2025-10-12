defmodule Gotham.TimeTracking.TimeEntry do
  use Ecto.Schema
  import Ecto.Changeset

  alias Gotham.Accounts.User

  schema "time_entries" do
    field :clock_in, :utc_datetime
    field :clock_out, :utc_datetime
    field :total_hours, :decimal
    field :work_location, :string
    field :notes, :string
    field :latitude, :decimal
    field :longitude, :decimal
    field :status, :string
    field :is_manual, :boolean, default: false
    field :justification, :string
    field :approved_by, :id
    field :approved_at, :utc_datetime
    field :rejected_by, :id
    field :rejected_at, :utc_datetime
    field :approval_notes, :string
    field :rejection_reason, :string

    belongs_to :user, User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(time_entry, attrs) do
    time_entry
    |> cast(attrs, [
      :user_id, :clock_in, :clock_out, :total_hours, :work_location,
      :notes, :latitude, :longitude, :status, :is_manual, :justification,
      :approved_by, :approved_at, :rejected_by, :rejected_at,
      :approval_notes, :rejection_reason
    ])
    |> validate_required([:user_id, :clock_in, :work_location, :status])
    |> validate_inclusion(:work_location, ["WFO", "WFH", "Client Site", "Other"])
    |> validate_inclusion(:status, ["in_progress", "completed", "pending", "approved", "rejected"])
    |> validate_clock_times()
    |> calculate_total_hours()
  end

  defp validate_clock_times(changeset) do
    clock_in = get_field(changeset, :clock_in)
    clock_out = get_field(changeset, :clock_out)

    cond do
      is_nil(clock_in) ->
        changeset

      is_nil(clock_out) ->
        changeset

      DateTime.compare(clock_out, clock_in) == :lt ->
        add_error(changeset, :clock_out, "must be after clock in time")

      true ->
        changeset
    end
  end

  defp calculate_total_hours(changeset) do
    clock_in = get_field(changeset, :clock_in)
    clock_out = get_field(changeset, :clock_out)

    if clock_in && clock_out do
      hours = DateTime.diff(clock_out, clock_in, :second) / 3600.0
      put_change(changeset, :total_hours, Decimal.from_float(Float.round(hours, 2)))
    else
      changeset
    end
  end
end
