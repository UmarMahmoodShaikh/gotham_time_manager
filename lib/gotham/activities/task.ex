defmodule Gotham.Activities.Task do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tasks" do
    field :title, :string
    field :description, :string
    # pending | in_progress | done | dismissed
    field :status, :string, default: "pending"
    field :is_billable, :boolean, default: false
    field :assigned_user_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(task, attrs) do
    task
    |> cast(attrs, [:title, :description, :status, :is_billable, :assigned_user_id])
    |> validate_required([:title, :description, :status, :is_billable])
    |> validate_inclusion(:status, ["pending", "in_progress", "done", "dismissed"])
  end
end
