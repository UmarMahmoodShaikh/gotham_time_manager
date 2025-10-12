defmodule Gotham.Accounts.Session do
  use Ecto.Schema
  import Ecto.Changeset

  schema "sessions" do
    field :token, :string
    field :csrf_token, :string
    field :expires_at, :utc_datetime
    field :refresh_token, :string

    belongs_to :user, Gotham.Accounts.User

    timestamps(type: :utc_datetime)
  end

  def changeset(session, attrs) do
    session
    |> cast(attrs, [:user_id, :token, :csrf_token, :expires_at, :refresh_token])
    |> validate_required([:user_id, :token, :expires_at])
    |> unique_constraint(:token)
    |> foreign_key_constraint(:user_id)
  end
end
