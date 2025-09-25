defmodule GothamTimeManager.Repo.Migrations.AlterUsersAddUsernameEmail do
  use Ecto.Migration

  def up do
    alter table(:users) do
      add :username, :string
      add :email, :string
    end

    create unique_index(:users, [:email])
    alter table(:users) do
      modify :username, :string, null: false
      modify :email, :string, null: false
      remove :first_name
      remove :last_name
    end
  end

  def down do
    alter table(:users) do
      add :first_name, :string
      add :last_name, :string
    end

    drop_if_exists index(:users, [:email])
    drop_if_exists index(:users, [:username])

    alter table(:users) do
      remove :username
      remove :email
    end
  end
end
