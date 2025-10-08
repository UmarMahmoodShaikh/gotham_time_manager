defmodule Gotham.Repo.Migrations.AlterTasksStatusToString do
  use Ecto.Migration

  def change do
    alter table(:tasks) do
      modify :status, :string, null: false, default: "pending"
    end

    create constraint(:tasks, :task_status_must_be_valid,
             check: "status in ('pending','in_progress','done','dismissed')"
           )
  end
end
