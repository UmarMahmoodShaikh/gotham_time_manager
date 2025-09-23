defmodule GothamTimeManager.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias GothamTimeManager.Tasks.Task

  schema "users" do
    field :first_name, :string
    field :last_name, :string

    many_to_many :tasks, Task,
                 join_through: "tasks_users"

    timestamps(type: :utc_datetime)
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:first_name, :last_name])
    |> validate_required([:first_name, :last_name])
  end
end
