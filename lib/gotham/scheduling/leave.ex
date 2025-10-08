defmodule Gotham.Scheduling.Leave do
  use Ecto.Schema
  import Ecto.Changeset

  schema "leaves" do
    field :leave_type, :string
    field :start_date, :date
    field :end_date, :date
    field :status, :string
    field :user_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(leave, attrs) do
    leave
    |> cast(attrs, [:leave_type, :start_date, :end_date, :status])
    |> validate_required([:leave_type, :start_date, :end_date, :status])
  end
end
