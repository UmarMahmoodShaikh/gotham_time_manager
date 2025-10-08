defmodule Gotham.Accounts.Permission do
  use Ecto.Schema
  import Ecto.Changeset

  alias Gotham.Repo
  alias Gotham.Accounts.User

  schema "permissions" do
    field :permission_level, :string

    belongs_to :manager, User, foreign_key: :manager_id, type: :id
    belongs_to :managed_user, User, foreign_key: :managed_user_id, type: :id

    timestamps(type: :utc_datetime)
  end

  # Update or create a permission for the managed user
  def update_user_permission(user_id, attrs) do
    case Repo.get_by(__MODULE__, managed_user_id: user_id) do
      nil ->
        %__MODULE__{}
        |> changeset(Map.put(attrs, :managed_user_id, user_id))
        |> Repo.insert()

      permission ->
        permission
        |> changeset(attrs)
        |> Repo.update()
    end
  end

  # Revoke/delete permission by managed user id
  def revoke_user_permission(user_id) do
    case Repo.get_by(__MODULE__, managed_user_id: user_id) do
      nil -> {:error, :not_found}
      permission -> Repo.delete(permission)
    end
  end

  @doc false
  def changeset(permission, attrs) do
    permission
    |> cast(attrs, [:permission_level, :manager_id, :managed_user_id])
    |> validate_required([:permission_level, :manager_id, :managed_user_id])
    |> validate_inclusion(:permission_level, Gotham.Accounts.PermissionLevel.levels())
    |> assoc_constraint(:manager)
    |> assoc_constraint(:managed_user)
  end
end
