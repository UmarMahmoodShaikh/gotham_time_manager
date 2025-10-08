defmodule Gotham.Payroll.CompensationLog do
  use Ecto.Schema
  import Ecto.Changeset

  schema "compensation_logs" do
    field :pay_rate_type, :string
    field :hours_calculated, :decimal
    field :working_time_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(compensation_log, attrs) do
    compensation_log
    |> cast(attrs, [:pay_rate_type, :hours_calculated])
    |> validate_required([:pay_rate_type, :hours_calculated])
  end
end
