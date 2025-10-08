defmodule Gotham.Organizations.Team do
  use Ecto.Schema
  import Ecto.Changeset

  alias Gotham.Accounts.User
  alias Gotham.Organizations.{Project, TeamProject}

  schema "teams" do
    field :name, :string
    field :status, :string, default: "active"

    belongs_to :manager, User, foreign_key: :manager_id, type: :id
    many_to_many :projects, Project, join_through: TeamProject

    timestamps(type: :utc_datetime)
  end

  def changeset(team, attrs) do
    team
    |> cast(attrs, [:name, :status, :manager_id])
    |> validate_required([:name])
    |> validate_inclusion(:status, ["active", "dismissed"])
    |> unique_constraint(:name)
    |> assoc_constraint(:manager)
  end
end
