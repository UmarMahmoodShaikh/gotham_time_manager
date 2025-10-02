defmodule GothamTimeManager.Repo.Migrations.AddMissingFieldsToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :email, :string, null: false
      add :username, :string
    end

    create unique_index(:users, [:email])
  end
end
