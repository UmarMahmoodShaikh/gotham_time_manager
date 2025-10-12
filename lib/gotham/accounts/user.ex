defmodule Gotham.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Bcrypt

  schema "users" do
    field :username, :string
    field :email, :string
    field :personal_email, :string
    field :phone, :string
    field :first_name, :string
    field :last_name, :string
    field :password_hash, :string
    field :password, :string, virtual: true
    field :is_visually_challenged, :boolean, default: false
    field :is_active, :boolean, default: true
    field :department, :string
    field :position, :string
    field :status, :string, default: "active"
    field :hire_date, :date

    belongs_to :role, Gotham.Accounts.Role
    belongs_to :manager, Gotham.Accounts.User
    has_many :managed_users, Gotham.Accounts.User, foreign_key: :manager_id
    has_many :working_times, Gotham.TimeTracking.WorkingTime
    has_many :sessions, Gotham.Accounts.Session

    timestamps(type: :utc_datetime)
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [
      :email,
      :personal_email,
      :phone,
      :password,
      :username,
      :first_name,
      :last_name,
      :is_visually_challenged,
      :is_active,
      :role_id,
      :department,
      :position,
      :manager_id,
      :status,
      :hire_date
    ])
    |> validate_required([:personal_email, :first_name, :last_name])
    |> validate_format(:personal_email, ~r/@/)
    |> validate_length(:password, min: 6)
    |> default_role_id()
    |> put_password_hash()
    |> unique_constraint(:email)
    |> unique_constraint(:personal_email)
    |> unique_constraint(:username)
  end

  defp default_role_id(changeset) do
    case get_field(changeset, :role_id) do
      nil -> put_change(changeset, :role_id, Gotham.Accounts.Role.employee_id())
      _ -> changeset
    end
  end

  defp put_password_hash(changeset) do
    case get_change(changeset, :password) do
      nil -> changeset
      password -> put_change(changeset, :password_hash, Bcrypt.hash_pwd_salt(password))
    end
  end

  def create_user(attrs) do
    %__MODULE__{}
    |> changeset(attrs)
    |> Gotham.Repo.insert()
  end
end
