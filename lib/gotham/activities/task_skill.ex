defmodule Gotham.Activities.TaskSkill do
  use Ecto.Schema
  import Ecto.Changeset

  schema "task_skills" do
    field :task_id, :id
    field :skill_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(task_skill, attrs) do
    task_skill
    |> cast(attrs, [])
    |> validate_required([])
  end
end
