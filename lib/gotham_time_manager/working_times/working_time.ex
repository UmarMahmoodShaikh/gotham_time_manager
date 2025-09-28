defmodule GothamTimeManager.WorkingTimes.WorkingTime do
  use Ecto.Schema
  import Ecto.Changeset

  alias GothamTimeManager.Accounts.User

  schema "working_times" do
    field :start, :utc_datetime
    field :end, :utc_datetime
    belongs_to :user, User

    timestamps(type: :utc_datetime)
  end

  def changeset(working_time, attrs) do
    working_time
    |> cast(attrs, [:start, :end, :user_id])
    |> validate_required([:start, :end, :user_id])
    |> validate_start_before_end()
    |> assoc_constraint(:user)
  end

  defp validate_start_before_end(changeset) do
    start_dt = get_field(changeset, :start)
    end_dt = get_field(changeset, :end)

    cond do
      is_nil(start_dt) or is_nil(end_dt) ->
        changeset

      DateTime.compare(start_dt, end_dt) == :gt ->
        add_error(changeset, :start, "must be before end")

      true ->docker push umarshk7/gotham_time_manager:latest
        changeset
    end
  end
end
