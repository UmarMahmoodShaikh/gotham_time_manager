defmodule Gotham.Repo.Migrations.CreateRoles do
  use Ecto.Migration

  def change do
    create table(:roles) do
      add :label, :string

      timestamps(type: :utc_datetime)
    end
  end
end
