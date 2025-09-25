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
    |> validate_change(:start, fn :start, start_dt ->
      end_dt = get_field(%{working_time | start: start_dt}, :end)
      cond do
        is_nil(end_dt) ->
          []
        DateTime.compare(start_dt, end_dt) == :gt ->
          [start: "must be before end"]
        true ->
          []
      end
    end)
    |> assoc_constraint(:user)
  end
end
