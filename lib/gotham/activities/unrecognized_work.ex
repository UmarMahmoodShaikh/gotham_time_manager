defmodule Gotham.Activities.UnrecognizedWork do
  use Ecto.Schema
  import Ecto.Changeset

  schema "unrecognized_works" do
    field :description, :string
    field :working_time_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(unrecognized_work, attrs) do
    unrecognized_work
    |> cast(attrs, [:description])
    |> validate_required([:description])
  end
end
