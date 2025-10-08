defmodule Gotham.Repo.Migrations.CreateLeaves do
  use Ecto.Migration

  def change do
    create table(:leaves) do
      add :leave_type, :string
      add :start_date, :date
      add :end_date, :date
      add :status, :string
      add :user_id, references(:users, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:leaves, [:user_id])
  end
end
