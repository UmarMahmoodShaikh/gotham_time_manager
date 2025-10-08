defmodule Gotham.Activities.TaskAssignment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "task_assignments" do
    field :task_id, :id
    field :user_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(task_assignment, attrs) do
    task_assignment
    |> cast(attrs, [:task_id, :user_id])
    |> validate_required([:task_id, :user_id])
    |> unique_constraint([:task_id, :user_id], name: :task_assignments_task_id_user_id_index)
  end
end
