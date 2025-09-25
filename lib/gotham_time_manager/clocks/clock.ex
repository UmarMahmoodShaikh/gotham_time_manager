defmodule GothamTimeManager.Clocks.Clock do
  use Ecto.Schema
  import Ecto.Changeset

  alias GothamTimeManager.Accounts.User

  schema "clocks" do
    field :time, :utc_datetime
    field :status, :boolean, default: false
    belongs_to :user, User

    timestamps(type: :utc_datetime)
  end

  def changeset(clock, attrs) do
    clock
    |> cast(attrs, [:time, :status, :user_id])
    |> validate_required([:time, :status, :user_id])
    |> assoc_constraint(:user)
  end
end
