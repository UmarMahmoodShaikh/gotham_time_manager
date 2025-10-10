defmodule Gotham.Repo.Migrations.AddFieldsToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :phone, :varchar, size: 15
      add :personal_email, :string
      add :is_active, :boolean, default: true, null: false
    end
  end
end
