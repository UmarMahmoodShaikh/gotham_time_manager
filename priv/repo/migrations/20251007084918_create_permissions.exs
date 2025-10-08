defmodule Gotham.Repo.Migrations.CreatePermissions do
  use Ecto.Migration

  def change do
    create table(:permissions) do
      add :permission_level, :string
      add :manager_id, references(:users, on_delete: :nothing)
      add :managed_user_id, references(:users, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:permissions, [:manager_id])
    create index(:permissions, [:managed_user_id])
  end
end
