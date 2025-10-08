defmodule Gotham.Activities.Skill do
  use Ecto.Schema
  import Ecto.Changeset

  schema "skills" do
    field :label, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(skill, attrs) do
    skill
    |> cast(attrs, [:label])
    |> validate_required([:label])
  end
end
