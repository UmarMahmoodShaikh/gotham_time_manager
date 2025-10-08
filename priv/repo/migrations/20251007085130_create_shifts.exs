defmodule Gotham.Repo.Migrations.CreateShifts do
  use Ecto.Migration

  def change do
    create table(:shifts) do
      add :name, :string
      add :is_night_shift, :boolean, default: false, null: false
      add :is_constraint_hour, :boolean, default: false, null: false

      timestamps(type: :utc_datetime)
    end
  end
end
