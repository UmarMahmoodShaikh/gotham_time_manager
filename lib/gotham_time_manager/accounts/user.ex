defmodule GothamTimeManager.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias GothamTimeManager.Tasks.Task

  schema "users" do
    field :username, :string
    field :email, :string

    many_to_many :tasks, Task,
                 join_through: "tasks_users"

    timestamps(type: :utc_datetime)
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:username, :email])
    |> validate_required([:username, :email])
    |> validate_format(:email, ~r/^.+@.+\..+$/)
    |> unsafe_validate_unique(:email, GothamTimeManager.Repo)
    |> unsafe_validate_unique(:username, GothamTimeManager.Repo)
    |> unique_constraint(:email)
    |> unique_constraint(:username)
  end
end
