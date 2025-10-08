defmodule Gotham.Integrations.Integration do
  use Ecto.Schema
  import Ecto.Changeset

  schema "integrations" do
    field :system_name, :string
    field :last_trigger_time, :utc_datetime
    field :is_active, :boolean, default: false

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(integration, attrs) do
    integration
    |> cast(attrs, [:system_name, :last_trigger_time, :is_active])
    |> validate_required([:system_name, :last_trigger_time, :is_active])
  end
end
