defmodule Gotham.Activities.UserSkill do
  use Ecto.Schema
  import Ecto.Changeset

  schema "user_skills" do
    field :user_id, :id
    field :skill_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user_skill, attrs) do
    user_skill
    |> cast(attrs, [:user_id, :skill_id])
    |> validate_required([:user_id, :skill_id])
    |> unique_constraint([:user_id, :skill_id], name: :user_skills_user_id_skill_id_index)
  end
end
