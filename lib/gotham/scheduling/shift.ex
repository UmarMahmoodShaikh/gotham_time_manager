defmodule Gotham.Scheduling.Shift do
  use Ecto.Schema
  import Ecto.Changeset

  schema "shifts" do
    field :name, :string
    field :is_night_shift, :boolean, default: false
    field :is_constraint_hour, :boolean, default: false

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(shift, attrs) do
    shift
    |> cast(attrs, [:name, :is_night_shift, :is_constraint_hour])
    |> validate_required([:name, :is_night_shift, :is_constraint_hour])
  end
end
