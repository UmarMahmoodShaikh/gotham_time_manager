defmodule Gotham.Repo.Migrations.CreateIntegrations do
  use Ecto.Migration

  def change do
    create table(:integrations) do
      add :system_name, :string
      add :last_trigger_time, :utc_datetime
      add :is_active, :boolean, default: false, null: false

      timestamps(type: :utc_datetime)
    end
  end
end
