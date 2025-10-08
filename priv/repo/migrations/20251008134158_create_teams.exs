defmodule Gotham.Repo.Migrations.CreateTeams do
  use Ecto.Migration

  def change do
    create table(:teams) do
      add :name, :string, null: false
      # active | dismissed
      add :status, :string, null: false, default: "active"
      add :manager_id, references(:users, on_delete: :nilify_all)

      timestamps(type: :utc_datetime)
    end

    create unique_index(:teams, [:name])
    create index(:teams, [:manager_id])
    create constraint(:teams, :status_must_be_valid, check: "status in ('active','dismissed')")
  end
end
