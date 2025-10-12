defmodule Gotham.Repo.Migrations.AddMissingFieldsToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :department, :string
      add :position, :string
      add :manager_id, references(:users, on_delete: :nilify_all)
      add :status, :string, default: "active"
      add :hire_date, :date
    end

    create index(:users, [:manager_id])
    create index(:users, [:status])
    create index(:users, [:department])
  end
end