defmodule GothamTimeManager.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias GothamTimeManager.Tasks.Task

  schema "users" do
    field :first_name, :string
    field :last_name, :string
    field :email, :string
    field :role, :string
    field :password, :string, virtual: true
    field :hashed_password, :string
    field :username, :string

    many_to_many :tasks, Task,
                 join_through: "tasks_users"

    timestamps(type: :utc_datetime)
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:first_name, :last_name, :email, :role, :password, :username])
    |> validate_required([:first_name, :email, :role, :password])
    |> put_hashed_password()
  end

  defp put_hashed_password(changeset) do
    case get_change(changeset, :password) do
      nil -> changeset
      password ->
        put_change(changeset, :hashed_password, Bcrypt.hash_pwd_salt(password))
    end
  end
end
