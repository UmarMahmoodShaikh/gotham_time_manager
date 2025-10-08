defmodule Gotham.Repo.Migrations.CreateProjects do
  use Ecto.Migration

  def change do
    create table(:projects) do
      add :name, :string, null: false
      add :description, :text
      # active | completed | cancelled
      add :status, :string, null: false, default: "active"

      timestamps(type: :utc_datetime)
    end

    create unique_index(:projects, [:name])

    create constraint(:projects, :project_status_must_be_valid,
             check: "status in ('active','completed','cancelled')"
           )
  end
end
